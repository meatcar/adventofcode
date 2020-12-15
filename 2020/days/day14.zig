usingnamespace @import("./common.zig");

const MemType = struct {
    addr: u64,
    val: u64,
};

const Op = union(enum) {
    Mask: []const u8,
    Mem: MemType,
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) ![]Op {
    var count: usize = 0;
    var file_it = mem.tokenize(file, "\n");
    while (file_it.next()) |line| count += 1;

    var input = try allocator.alloc(Op, count);
    file_it = mem.tokenize(file, "\n");
    var i: usize = 0;
    while (file_it.next()) |line| {
        var line_it = mem.tokenize(line, " =");
        const lhs = line_it.next().?;
        const rhs = line_it.next().?;

        var op: Op = undefined;

        if (mem.startsWith(u8, line, "mask")) {
            op = Op{ .Mask = rhs };
        } else {
            var lhs_it = mem.tokenize(lhs, "[]");
            _ = lhs_it.next();
            const addr = try parseInt(u64, lhs_it.next().?, 10);
            const val = try parseInt(u64, rhs, 10);
            op = Op{ .Mem = MemType{ .addr = addr, .val = val } };
        }

        input[i] = op;
        i += 1;
    }
    return input;
}

const test_input =
    \\mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    \\mem[8] = 11
    \\mem[7] = 101
    \\mem[8] = 0
;

test "cleanInput" {
    var input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input);

    const answer = &[_]Op{
        .{ .Mask = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X" },
        .{ .Mem = .{ .addr = 8, .val = 11 } },
        .{ .Mem = .{ .addr = 7, .val = 101 } },
        .{ .Mem = .{ .addr = 8, .val = 0 } },
    };

    for (answer) |a, i| {
        switch (a) {
            .Mask => {
                testing.expectEqualSlices(u8, a.Mask, input[i].Mask);
            },
            .Mem => {
                testing.expectEqual(a.Mem.addr, input[i].Mem.addr);
                testing.expectEqual(a.Mem.val, input[i].Mem.val);
            },
        }
    }
}

pub fn part1(allocator: *mem.Allocator, input: []const Op) !u64 {
    var mask: []const u8 = undefined;
    var memory = std.AutoHashMap(u64, u64).init(allocator);
    defer memory.deinit();

    for (input) |op| {
        if (op == .Mask) {
            mask = op.Mask;
            continue;
        }

        var v = op.Mem.val;
        for (mask) |c, i| {
            if (c == 'X') continue;

            const bit = @as(u64, 1) << @intCast(u6, mask.len - i - 1);
            if (c == '1') {
                v |= bit;
            } else {
                v &= ~bit;
            }
        }
        _ = try memory.put(op.Mem.addr, v);
    }

    var memory_it = memory.iterator();
    var sum: u64 = 0;
    while (memory_it.next()) |kv| {
        sum += kv.value;
    }
    return sum;
}

test "part1" {
    const input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input);
    testing.expectEqual(@intCast(u64, 165), try part1(testing.allocator, input));
}

pub fn part2(allocator: *mem.Allocator, input: []const Op) !u64 {
    var mask: []const u8 = undefined;
    var memory = std.AutoHashMap(u64, u64).init(allocator);
    defer memory.deinit();

    for (input) |op| {
        if (op == .Mask) {
            mask = op.Mask;
            continue;
        }

        var addr = op.Mem.addr;
        var addrs = ArrayList(u64).init(allocator);
        defer addrs.deinit();
        try addrs.append(addr);
        for (mask) |c, i| {
            const bit = @intCast(u6, mask.len - i - 1);
            const addr_bit = (addr >> bit) & 1;
            switch (c) {
                '0' => {},
                '1' => {
                    for (addrs.items) |*a| {
                        a.* |= @as(u64, 1) << bit;
                    }
                },
                'X' => {
                    for (addrs.items) |*a| {
                        a.* |= @as(u64, 1) << bit;
                        try addrs.append(a.* & ~(@as(u64, 1) << bit));
                    }
                },
                else => unreachable,
            }
        }

        for (addrs.items) |a| {
            _ = try memory.put(a, op.Mem.val);
        }
    }

    var memory_it = memory.iterator();
    var sum: u64 = 0;
    while (memory_it.next()) |kv| {
        sum += kv.value;
    }
    return sum;
}

test "part2" {
    var input = try cleanInput(testing.allocator,
        \\mask = 000000000000000000000000000000X1001X
        \\mem[42] = 100
        \\mask = 00000000000000000000000000000000X0XX
        \\mem[26] = 1
    );
    testing.expectEqual(@intCast(u64, 208), try part2(testing.allocator, input));
    testing.allocator.free(input);
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day14.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer alloc.free(input);

    warn("part1: {}\n", .{try part1(alloc, input)});
    warn("part2: {}\n", .{try part2(alloc, input)});
}
