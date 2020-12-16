usingnamespace @import("./common.zig");

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) ![]u64 {
    var count: usize = 0;
    var file_it = mem.tokenize(file, ",\n");
    while (file_it.next()) |line| count += 1;

    var input = try allocator.alloc(u64, count);
    file_it = mem.tokenize(file, ",\n");
    var i: usize = 0;
    while (file_it.next()) |n| {
        input[i] = try parseInt(u64, n, 10);
        i += 1;
    }
    return input;
}

const test_input =
  \\0,3,6
;

test "cleanInput" {
    var input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input);

    const answer = &[_]u64{0, 3, 6};
    testing.expectEqualSlices(u64, answer, input);
}

fn playGame(allocator: *mem.Allocator, input: []u64, n_turns: u64) !u64 {
    // number => .{last_turn_seen}
    var last = try allocator.alloc(u64, n_turns + 1);
    defer allocator.free(last);

    mem.set(u64, last, 0);

    var i: u64 = 1;
    var n: u64 = undefined;

    for (input) |num| {
        n = num;
        last[n] = i;
        i += 1;
    }

    while (i <= n_turns) : (i += 1) {
        const prev = last[n];
        last[n] = i - 1;
        n = if (prev == 0) 0 else i - 1 - prev;
    }

    return n;
}

pub fn part1(allocator: *mem.Allocator, input: []u64) !u64 {
    return playGame(allocator, input, 2020);
}

test "part1" {
    var input = try cleanInput(testing.allocator, test_input);
    testing.expectEqual(@intCast(u64, 436), try part1(testing.allocator, input));
    testing.allocator.free(input);

    input = try cleanInput(testing.allocator, "1,3,2");
    testing.expectEqual(@intCast(u64, 1), try part1(testing.allocator, input));
    testing.allocator.free(input);

    input = try cleanInput(testing.allocator, "2,1,3");
    testing.expectEqual(@intCast(u64, 10), try part1(testing.allocator, input));
    testing.allocator.free(input);

    input = try cleanInput(testing.allocator, "1,2,3");
    testing.expectEqual(@intCast(u64, 27), try part1(testing.allocator, input));
    testing.allocator.free(input);

    input = try cleanInput(testing.allocator, "2,3,1");
    testing.expectEqual(@intCast(u64, 78), try part1(testing.allocator, input));
    testing.allocator.free(input);

    input = try cleanInput(testing.allocator, "3,2,1");
    testing.expectEqual(@intCast(u64, 438), try part1(testing.allocator, input));
    testing.allocator.free(input);

    input = try cleanInput(testing.allocator, "3,1,2");
    testing.expectEqual(@intCast(u64, 1836), try part1(testing.allocator, input));
    testing.allocator.free(input);
}

pub fn part2(allocator: *mem.Allocator, input: []u64) !u64 {
    return playGame(allocator, input, 30000000);
}

test "part2" {
    const allocator = alloc;
    var input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 175594), try part2(allocator, input));
    allocator.free(input);

    input = try cleanInput(allocator, "1,3,2");
    testing.expectEqual(@intCast(u64, 2578), try part2(allocator, input));
    allocator.free(input);

    input = try cleanInput(allocator, "2,1,3");
    testing.expectEqual(@intCast(u64, 3544142), try part2(allocator, input));
    allocator.free(input);

    input = try cleanInput(allocator, "1,2,3");
    testing.expectEqual(@intCast(u64, 261214), try part2(allocator, input));
    allocator.free(input);

    input = try cleanInput(allocator, "2,3,1");
    testing.expectEqual(@intCast(u64, 6895259), try part2(allocator, input));
    allocator.free(input);

    input = try cleanInput(allocator, "3,2,1");
    testing.expectEqual(@intCast(u64, 18), try part2(allocator, input));
    allocator.free(input);

    input = try cleanInput(allocator, "3,1,2");
    testing.expectEqual(@intCast(u64, 362), try part2(allocator, input));
    allocator.free(input);
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day15.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer alloc.free(input);

    warn("part1: {}\n", .{try part1(alloc, input)});
    warn("part2: {}\n", .{try part2(alloc, input)});
}
