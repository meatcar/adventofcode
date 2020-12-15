usingnamespace @import("./common.zig");

const Input = struct {
    time: u64,
    ids: []const u64,
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !*Input {
    var input = try allocator.create(Input);
    var lines = mem.tokenize(file, "\n");
    input.time = try parseInt(u64, lines.next().?, 10);
    var ids_str = lines.next().?;

    var count: usize = 0;
    var entries = mem.tokenize(ids_str, ",");
    while (entries.next()) |entry| count += 1;

    var ids = try allocator.alloc(u64, count);
    entries = mem.tokenize(ids_str, ",");
    var i: usize = 0;
    while (entries.next()) |bus| {
        ids[i] = parseInt(u64, bus, 10) catch 0;
        i += 1;
    }
    input.ids = ids;
    return input;
}

const test_input =
    \\939
    \\7,13,x,x,59,x,31,19
;

test "cleanInput" {
    var input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input.ids);
    defer testing.allocator.destroy(input);

    testing.expectEqual(@intCast(u64, 939), input.time);
    testing.expectEqualSlices(u64, &[_]u64{ 7, 13, 0, 0, 59, 0, 31, 19 }, input.ids);
}

fn timeUntilDeparture(id: u64, time: u64) u64 {
    return id - @mod(time, id);
}

pub fn part1(input: Input) !u64 {
    var min: u64 = input.ids[0];
    for (input.ids) |bus| {
        if (bus == 0) continue;

        const next_bus = timeUntilDeparture(bus, input.time);
        const next_min = timeUntilDeparture(min, input.time);
        if (next_bus < next_min)
            min = bus;
    }
    return min * timeUntilDeparture(min, input.time);
}

test "part1" {
    const input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input.ids);
    defer testing.allocator.destroy(input);
    testing.expectEqual(@intCast(u64, 295), try part1(input.*));
}

pub fn part2(allocator: *mem.Allocator, input: Input) !u64 {
    var remainders = try allocator.alloc(u64, input.ids.len);
    defer allocator.free(remainders);
    for (input.ids) |id, i| {
        if (id == 0) continue;
        remainders[i] = @intCast(u64, @mod(@intCast(i64, id) - @intCast(i64, i), @intCast(i64, id)));
    }

    var time: u64 = 0;
    var step: u64 = 1;

    for (input.ids) |id, i| {
        if (id == 0) continue;
        while (@mod(time, id) != remainders[i])
            time += step;
        step *= id;
    }

    return time;
}

test "part2" {
    var input = try cleanInput(testing.allocator, test_input);
    testing.expectEqual(@intCast(u64, 1068781), try part2(testing.allocator, input.*));
    testing.allocator.free(input.ids);
    testing.allocator.destroy(input);

    input = try cleanInput(testing.allocator,
        \\0
        \\17,x,13,19
    );
    testing.expectEqual(@intCast(u64, 3417), try part2(testing.allocator, input.*));
    testing.allocator.free(input.ids);
    testing.allocator.destroy(input);

    input = try cleanInput(testing.allocator,
        \\0
        \\67,7,59,61
    );
    testing.expectEqual(@intCast(u64, 754018), try part2(testing.allocator, input.*));
    testing.allocator.free(input.ids);
    testing.allocator.destroy(input);

    input = try cleanInput(testing.allocator,
        \\0
        \\67,x,7,59,61
    );
    testing.expectEqual(@intCast(u64, 779210), try part2(testing.allocator, input.*));
    testing.allocator.free(input.ids);
    testing.allocator.destroy(input);

    input = try cleanInput(testing.allocator,
        \\0
        \\67,7,x,59,61
    );
    testing.expectEqual(@intCast(u64, 1261476), try part2(testing.allocator, input.*));
    testing.allocator.free(input.ids);
    testing.allocator.destroy(input);

    input = try cleanInput(testing.allocator,
        \\0
        \\1789,37,47,1889
    );
    testing.expectEqual(@intCast(u64, 1202161486), try part2(testing.allocator, input.*));
    testing.allocator.free(input.ids);
    testing.allocator.destroy(input);
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day13.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer alloc.destroy(input);

    warn("part1: {}\n", .{try part1(input.*)});
    warn("part2: {}\n", .{try part2(alloc, input.*)});
}
