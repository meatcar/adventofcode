usingnamespace @import("./common.zig");

const Atom = union(enum) {
    Int: u64,
    Paren: u8,
    Op: u8,
};

const Input = struct {
    const Self = @This();

    exprs: [][]Atom,
    allocator: *mem.Allocator,

    pub fn init(allocator: *mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .exprs = undefined,
        };
    }

    pub fn deinit(self: Self) void {
        for (self.exprs) |expr| self.allocator.free(expr);
        self.allocator.free(self.exprs);
    }
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !Input {
    var input: Input = try Input.init(allocator);
    var exprs = ArrayList([]Atom).init(allocator);

    var file_it = mem.tokenize(file, "\n");
    while (file_it.next()) |line| {
        var expr = ArrayList(Atom).init(allocator);
        defer expr.deinit();
        for (line) |c, i| {
            var atom: Atom = switch (c) {
                ' ' => continue,
                '+', '*' => Atom{ .Op = c },
                '(', ')' => Atom{ .Paren = c },
                else => Atom{ .Int = try parseInt(u64, line[i .. i + 1], 10) },
            };
            try expr.append(atom);
        }

        try exprs.append(expr.toOwnedSlice());
    }

    input.exprs = exprs.toOwnedSlice();
    return input;
}

const test_input =
    \\2 * 3 + (4 * 5)
    \\5 + (8 * 3 + 9 + 3 * 4 * 3)
    \\5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
    \\((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
;

test "cleanInput" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, test_input);
    defer input.deinit();

    var answer = [_]Atom{
        Atom{ .Int = 2 },
        Atom{ .Op = '*' },
        Atom{ .Int = 3 },
        Atom{ .Op = '+' },
        Atom{ .Paren = '(' },
        Atom{ .Int = 4 },
        Atom{ .Op = '*' },
        Atom{ .Int = 5 },
        Atom{ .Paren = ')' },
    };
    testing.expectEqualSlices(Atom, &answer, input.exprs[0]);
}

const Error = error{
//Allocator
OutOfMemory};

fn printAtom(atom: Atom) void {
    switch (atom) {
        .Int => |i| warn("{}", .{i}),
        .Op => |c| warn("{c}", .{c}),
        .Paren => |p| warn("{c}", .{p}),
    }
}

fn findOp(expr: []Atom) usize {
    var index: ?usize = null;

    for (expr) |atom, i| {
        if (index == null and atom == .Op) {
            index = i;
        } else if (atom == .Paren and atom.Paren == '(') {
            index = null;
        } else if (atom == .Paren and atom.Paren == ')') {
            break;
        }
    }
    return index.?;
}

/// Calculate the result of a given expression by running doOpFn on it repeatedly.
fn calculate(allocator: *mem.Allocator, findOpFn: var, str: []Atom) Error!u64 {
    var expr = try mem.dupe(allocator, Atom, str);
    defer allocator.free(expr);
    while (expr.len > 1) {
        const op_idx = findOpFn(expr);

        const lhs = expr[op_idx - 1].Int;
        const rhs = expr[op_idx + 1].Int;

        var n = switch (expr[op_idx].Op) {
            '+' => Atom{ .Int = lhs + rhs },
            '*' => Atom{ .Int = lhs * rhs },
            else => unreachable,
        };

        // make a new expression
        var cut_start = op_idx - 1;
        var cut_end = op_idx + 1;
        if (op_idx >= 2 and expr[op_idx - 2] == .Paren and expr[op_idx + 2] == .Paren) {
            cut_start -= 1;
            cut_end += 1;
        }
        var new_expr = try mem.concat(allocator, Atom, &[_][]Atom{
            expr[0..cut_start],
            &[_]Atom{n},
            expr[cut_end + 1 ..],
        });
        mem.swap([]Atom, &expr, &new_expr);
        allocator.free(new_expr);
    }
    return expr[0].Int;
}

pub fn part1(allocator: *mem.Allocator, input: Input) !u64 {
    var sum: u64 = 0;
    for (input.exprs) |expr| {
        const n = try calculate(allocator, findOp, expr);
        sum += n;
    }
    return sum;
}

test "part1" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 26 + 437 + 12240 + 13632), try part1(allocator, input));
    input.deinit();
}

fn findOpPrioritizeAdding(expr: []Atom) usize {
    var prev_atom: Atom = undefined;
    var index: ?usize = null;

    for (expr) |atom, i| {
        if (atom == .Op) {
            if (index == null or (atom.Op == '+' and prev_atom.Op == '*')) {
                prev_atom = atom;
                index = i;
            }
        } else if (atom == .Paren and atom.Paren == '(') {
            index = null;
        } else if (atom == .Paren and atom.Paren == ')') {
            break;
        }
    }
    return index.?;
}

pub fn part2(allocator: *mem.Allocator, input: Input) !u64 {
    var sum: u64 = 0;
    for (input.exprs) |expr| {
        const n = try calculate(allocator, findOpPrioritizeAdding, expr);
        sum += n;
    }
    return sum;
}

test "part2" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, "1 + 2 * 3 + 4 * 5 + 6");
    testing.expectEqual(@intCast(u64, 231), try part2(allocator, input));
    input.deinit();
    input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 46 + 1445 + 669060 + 23340), try part2(allocator, input));
    input.deinit();
}

pub fn main() !void {
    const allocator = default_allocator;
    const file = try common.readFile(alloc, "inputs/day18.txt");
    defer alloc.free(file);
    const input = try cleanInput(allocator, file);
    defer input.deinit();

    warn("part1: {}\n", .{try part1(allocator, input)});
    warn("part2: {}\n", .{try part2(allocator, input)});
}
