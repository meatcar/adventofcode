usingnamespace @import("./common.zig");

const directions = [8][2]isize{
    .{ 1, 1 },
    .{ 1, -1 },
    .{ 1, 0 },
    .{ -1, 1 },
    .{ -1, -1 },
    .{ -1, 0 },
    .{ 0, 1 },
    .{ 0, -1 },
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !ArrayList([]const u8) {
    var input = ArrayList([]const u8).init(allocator);

    var line_it = mem.tokenize(file, "\n");
    while (line_it.next()) |line|
        try input.append(line);

    return input;
}

const test_input =
    \\L.LL.LL.LL
    \\LLLLLLL.LL
    \\L.L.L..L..
    \\LLLL.LL.LL
    \\L.LL.LL.LL
    \\L.LLLLL.LL
    \\..L.L.....
    \\LLLLLLLLLL
    \\L.LLLLLL.L
    \\L.LLLLL.LL
;

test "cleanInput" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();

    var answer = [_][]const u8{
        "L.LL.LL.LL",
        "LLLLLLL.LL",
        "L.L.L..L..",
        "LLLL.LL.LL",
        "L.LL.LL.LL",
        "L.LLLLL.LL",
        "..L.L.....",
        "LLLLLLLLLL",
        "L.LLLLLL.L",
        "L.LLLLL.LL",
    };

    for (answer) |line, i| {
        testing.expectEqualSlices(u8, line, input.items[i]);
    }
}

/// loop once, using callback to get each new state of a seat.
fn loop(allocator: *mem.Allocator, boat_ptr: *[][]u8, lookFn: var) !u64 {
    var boat = boat_ptr.*;
    var new_boat = try mem.dupe(allocator, []u8, boat);
    for (boat) |row, i|
        new_boat[i] = try mem.dupe(allocator, u8, row);

    defer allocator.free(new_boat);
    defer for (new_boat) |row| allocator.free(row);

    var changed: u64 = 0;
    for (boat) |row, x| {
        for (row) |seat, y| {
            const new_seat = lookFn(boat, x, y);
            if (new_seat != seat) changed += 1;
            new_boat[x][y] = new_seat;
        }
    }

    // copy new_boat to old_boat
    for (new_boat) |row, i| {
        for (row) |c, j| {
            boat[i][j] = c;
        }
    }
    return changed;
}

/// return 1 if someone is seated at the immediately adjacent tile in the given direction
fn lookClose(boat: [][]u8, px: usize, py: usize) u8 {
    var occupied: u64 = 0;
    for (directions) |d| {
        var x = @intCast(isize, px) + d[0];
        var y = @intCast(isize, py) + d[1];

        if (x >= 0 and x < boat.len and y >= 0 and y < boat[0].len) {
            const c = boat[@intCast(usize, x)][@intCast(usize, y)];
            if (c == '#') occupied += 1;
        }
    }

    const c = boat[px][py];
    return switch (c) {
        '#' => if (occupied >= 4) 'L' else c,
        'L' => if (occupied == 0) '#' else c,
        else => c,
    };
}

/// return 1 if someone is seated in the given direction
fn lookFar(boat: [][]u8, px: usize, py: usize) u8 {
    var occupied: u64 = 0;
    for (directions) |d| {
        var x = @intCast(isize, px) + d[0];
        var y = @intCast(isize, py) + d[1];
        while (x >= 0 and x < boat.len and y >= 0 and y < boat[0].len) {
            const c = boat[@intCast(usize, x)][@intCast(usize, y)];

            if (c == '#') occupied += 1;
            if (c == '#' or c == 'L') break;

            x += d[0];
            y += d[1];
        }
    }

    const c = boat[px][py];
    return switch (c) {
        '#' => if (occupied >= 5) 'L' else c,
        'L' => if (occupied == 0) '#' else c,
        else => c,
    };
}

/// loop until stable state achieved, returning the number of occupied seats
fn loopUntilStable(allocator: *mem.Allocator, input: ArrayList([]const u8), lookFn: var) !u64 {
    // clone input into writeable arrays
    var boat = try allocator.alloc([]u8, input.items.len);
    defer allocator.free(boat);

    for (input.items) |row, i| {
        var copy = try allocator.alloc(u8, row.len);
        for (row) |c, j| copy[j] = c;
        boat[i] = copy;
    }
    defer for (boat) |row| allocator.free(row);

    // loop
    var changed: u64 = 1;
    while (changed > 0) {
        changed = try loop(allocator, &boat, lookFn);
    }

    // count occupied
    var total: u64 = 0;
    for (boat) |row| {
        for (row) |seat| {
            if (seat == '#') total += 1;
        }
    }

    return total;
}

pub fn first(allocator: *mem.Allocator, input: ArrayList([]const u8)) !u64 {
    return loopUntilStable(allocator, input, lookClose);
}

test "first" {
    const input = try cleanInput(std.testing.allocator, test_input);
    testing.expectEqual(@intCast(u64, 37), try first(testing.allocator, input));
    input.deinit();
}

pub fn second(allocator: *mem.Allocator, input: ArrayList([]const u8)) !u64 {
    return loopUntilStable(allocator, input, lookFar);
}

test "second" {
    const input = try cleanInput(std.testing.allocator, test_input);
    testing.expectEqual(@intCast(u64, 26), try second(testing.allocator, input));
    input.deinit();
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day11.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const first_answer = try first(alloc, input);
    warn("first: {}\n", .{first_answer});

    const second_answer = try second(alloc, input);
    warn("second: {}\n", .{second_answer});
}
