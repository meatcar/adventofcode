usingnamespace @import("./common.zig");

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !std.ArrayList(u64) {
    var input = std.ArrayList(u64).init(allocator);

    var lines = mem.tokenize(file, "\n");
    while (lines.next()) |line| {
        try input.append(try parseInt(u64, line, 10));
    }
    return input;
}

const test_input1 =
    \\16
    \\10
    \\15
    \\5
    \\1
    \\11
    \\7
    \\19
    \\6
    \\12
    \\4
;

const test_input2 =
    \\28
    \\33
    \\18
    \\42
    \\31
    \\14
    \\46
    \\20
    \\48
    \\47
    \\24
    \\23
    \\49
    \\45
    \\19
    \\38
    \\39
    \\11
    \\1
    \\32
    \\25
    \\35
    \\8
    \\17
    \\7
    \\9
    \\4
    \\2
    \\34
    \\10
    \\3
;

test "cleanInput" {
    var input = try cleanInput(testing.allocator, test_input1);
    defer input.deinit();
    var answer = &[_]u64{
        16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4,
    };

    testing.expectEqualSlices(u64, answer, input.items);
}

pub fn part1(input: ArrayList(u64)) u64 {
    std.sort.sort(u64, input.items, std.sort.asc(u64));

    var deltas = [1]u64{0} ** 3;
    var prev: u64 = 0;

    for (input.items) |cur| {
        const d = cur - prev;
        prev = cur;
        if (d > 0 and d < 4) deltas[d - 1] += 1;
    }

    deltas[2] += 1;
    return deltas[0] * deltas[2];
}

test "part1" {
    const list = try cleanInput(testing.allocator, test_input1);
    defer list.deinit();
    testing.expectEqual(@intCast(u64, 7 * 5), part1(list));

    const list2 = try cleanInput(testing.allocator, test_input2);
    defer list2.deinit();
    testing.expectEqual(@intCast(u64, 22 * 10), part1(list2));
}

pub fn part2(allocator: *std.mem.Allocator, input: ArrayList(u64)) !u64 {
    std.sort.sort(u64, input.items, std.sort.asc(u64));

    // counts of contiguous groups of 1
    var groups = ArrayList(u64).init(allocator);
    defer groups.deinit();

    // number of deltas of 1 since last delta > 1
    var d1s: u64 = 0;
    var prev: u64 = 0;

    for (input.items) |cur, i| {
        const d = cur - prev;
        prev = cur;
        if (d == 1) {
            d1s += 1;
        } else {
            if (d1s > 1) try groups.append(d1s);
            d1s = 0;
        }
    }
    if (d1s > 0) try groups.append(d1s);

    var total: u64 = 1;
    for (groups.items) |i| {
        var combos: u64 = switch (i) {
            1 => 1,
            2 => 2,
            3 => 4,
            4 => 7,
            else => blk: {
                warn("unknown group size: {}\n", .{i});
                unreachable;
            },
        };
        total *= combos;
    }

    return total;
}

test "part2" {
    var list = try cleanInput(testing.allocator, test_input1);
    testing.expectEqual(@intCast(u64, 8), try part2(testing.allocator, list));
    list.deinit();

    list = try cleanInput(testing.allocator, test_input2);
    testing.expectEqual(@intCast(u64, 19208), try part2(testing.allocator, list));
    list.deinit();
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day10.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const part1_answer = part1(input);
    warn("part1: {}\n", .{part1_answer});

    const part2_answer = try part2(alloc, input);
    warn("part2: {}\n", .{part2_answer});
}
