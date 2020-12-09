usingnamespace @import("./common.zig");

const Instructions = enum {
    Nop, Acc, Jmp
};

const Instruction = struct {
    /// Operation
    op: Instructions,
    /// Argument
    arg: i64,
};
pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !ArrayList(Instruction) {
    var input = ArrayList(Instruction).init(allocator);

    var line_it = mem.tokenize(file, "\n");
    while (line_it.next()) |line| {
        var it = mem.tokenize(line, " ");
        const op_str = it.next().?;
        const arg_str = it.next().?;

        var op: Instructions = undefined;

        if (mem.eql(u8, op_str, "nop")) {
            op = .Nop;
        } else if (mem.eql(u8, op_str, "acc")) {
            op = .Acc;
        } else if (mem.eql(u8, op_str, "jmp")) {
            op = .Jmp;
        }

        try input.append(.{
            .op = op,
            .arg = try parseInt(i64, arg_str, 10),
        });
    }

    return input;
}

const test_input =
    \\nop +0
    \\acc +1
    \\jmp +4
    \\acc +3
    \\jmp -3
    \\acc -99
    \\acc +1
    \\jmp -4
    \\acc +6
;

test "cleanInput" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();

    var answer = ArrayList(Instruction).init(std.testing.allocator);
    defer answer.deinit();

    for (answer.items) |a, i| {
        testing.expectEqual(a.op, input.items[i].op);
        testing.expectEqual(a.arg, input.items[i].arg);
    }
}

const State = struct {
    /// Instruction Pointer
    ip: usize = 0,
    /// Accumulator
    acc: i64 = 0,
};

/// Run the instruction pointed to by state, and modify state accordingly.
fn runOnce(input: ArrayList(Instruction), state: *State) void {
    const ins = input.items[state.ip];
    switch (ins.op) {
        .Nop => {
            state.ip += 1;
        },
        .Acc => {
            state.ip += 1;
            state.acc += ins.arg;
        },
        .Jmp => {
            state.ip = @intCast(usize, @intCast(i64, state.ip) + ins.arg);
        },
    }
}

/// Run the input program until a loop is detected or the program exits.
fn runUntilLoop(input: ArrayList(Instruction), state: *State, allocator: *mem.Allocator) !void {
    var visited = std.AutoHashMap(usize, void).init(allocator);
    defer visited.deinit();

    while (state.ip < input.items.len and !visited.contains(state.ip)) {
        _ = try visited.put(state.ip, {});
        runOnce(input, state);
    }
}

pub fn first(allocator: *mem.Allocator, input: ArrayList(Instruction)) !i64 {
    var state: State = .{};

    try runUntilLoop(input, &state, allocator);

    return state.acc;
}

test "first" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();
    testing.expectEqual(@intCast(i64, 5), try first(std.testing.allocator, input));
}

pub fn second(allocator: *mem.Allocator, input: ArrayList(Instruction)) !i64 {
    var state: State = .{};
    var index: usize = 0;

    while (state.ip < input.items.len) : (index += 1) {
        state = .{};
        var ins = &input.items[index];
        ins.op = switch (ins.op) {
            .Jmp => .Nop,
            .Nop => .Jmp,
            else => continue,
        };
        try runUntilLoop(input, &state, allocator);

        // reverse swap.
        if (state.ip < input.items.len)
            ins.op = switch (ins.op) {
                .Jmp => .Nop,
                .Nop => .Jmp,
                else => unreachable,
            };
    }

    return state.acc;
}

test "second" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();
    testing.expectEqual(@intCast(i64, 8), try second(std.testing.allocator, input));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day8.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const first_answer = try first(alloc, input);
    warn("first: {}\n", .{first_answer});

    const second_answer = try second(alloc, input);
    warn("second: {}\n", .{second_answer});
}
