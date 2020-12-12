usingnamespace @import("./common.zig");

const Direction = enum { N, S, E, W, L, R, F };
const Move = struct {
    direction: Direction, arg: u64
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) ![]Move {
    var n_lines: u64 = 0;

    var lines = mem.tokenize(file, "\n");
    while (lines.next()) |line| n_lines += 1;

    var input: []Move = try allocator.alloc(Move, n_lines);

    lines = mem.tokenize(file, "\n");
    var i: usize = 0;
    while (lines.next()) |line| {
        input[i] = .{
            .direction = switch (line[0]) {
                'N' => .N,
                'S' => .S,
                'E' => .E,
                'W' => .W,
                'L' => .L,
                'R' => .R,
                'F' => .F,
                else => unreachable,
            },
            .arg = try parseInt(u64, line[1..], 10),
        };
        i += 1;
    }
    return input;
}

const test_input =
    \\F10
    \\N3
    \\F7
    \\R90
    \\F11
;

test "cleanInput" {
    var input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input);
    var answer = &[_]Move{
        Move{ .direction = .F, .arg = 10 },
        Move{ .direction = .N, .arg = 3 },
        Move{ .direction = .F, .arg = 7 },
        Move{ .direction = .R, .arg = 90 },
        Move{ .direction = .F, .arg = 11 },
    };

    for (answer) |a, i| {
        testing.expectEqual(a.direction, input[i].direction);
        testing.expectEqual(a.arg, input[i].arg);
    }
}

fn moveDirection(p: []i64, move: Move) void {
    const distance = @intCast(i64, move.arg);
    switch (move.direction) {
        .N => {
            p[1] += distance;
        },
        .S => {
            p[1] -= distance;
        },
        .E => {
            p[0] += distance;
        },
        .W => {
            p[0] -= distance;
        },
        else => unreachable,
    }
}

fn turn(move: Move, heading: Direction) Direction {
    if (move.direction == .L) {
        return switch (heading) {
            .N => .W,
            .E => .N,
            .S => .E,
            .W => .S,
            else => unreachable,
        };
    } else if (move.direction == .R) {
        return switch (heading) {
            .N => .E,
            .E => .S,
            .S => .W,
            .W => .N,
            else => unreachable,
        };
    } else unreachable;
}

pub fn part1(input: []const Move) !u64 {
    var heading = Direction.E;
    var p: [2]i64 = .{ 0, 0 };

    for (input) |move| {
        switch (move.direction) {
            .N, .E, .S, .W => {
                moveDirection(&p, move);
            },
            .F => {
                moveDirection(&p, .{
                    .direction = heading,
                    .arg = move.arg,
                });
            },
            .L, .R => {
                var degrees = move.arg;
                while (degrees > 0) : (degrees -= 90) {
                    heading = turn(move, heading);
                }
            },
        }
    }

    const dx: u64 = @intCast(u64, try math.absInt(p[0]));
    const dy: u64 = @intCast(u64, try math.absInt(p[1]));
    return dx + dy;
}

test "part1" {
    const input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input);
    testing.expectEqual(@intCast(u64, 25), try part1(input));
}

fn rotateWaypoint(wp: []i64, dir: Direction) void {
    switch (dir) {
        .L => {
            mem.swap(i64, &wp[0], &wp[1]);
            wp[0] *= -1;
        },
        .R => {
            mem.swap(i64, &wp[0], &wp[1]);
            wp[1] *= -1;
        },
        else => unreachable,
    }
}

pub fn part2(input: []const Move) !u64 {
    var heading = Direction.E;
    var ship: [2]i64 = .{ 0, 0 };
    var waypoint: [2]i64 = .{ 10, 1 };

    for (input) |move| {
        switch (move.direction) {
            .N, .E, .S, .W => {
                moveDirection(&waypoint, move);
            },
            .F => {
                var count: u64 = move.arg;
                while (count > 0) : (count -= 1) {
                    ship[0] += waypoint[0];
                    ship[1] += waypoint[1];
                }
            },
            .L, .R => {
                var degrees = move.arg;
                while (degrees > 0) : (degrees -= 90) {
                    rotateWaypoint(&waypoint, move.direction);
                }
            },
        }
    }

    const dx: u64 = @intCast(u64, try math.absInt(ship[0]));
    const dy: u64 = @intCast(u64, try math.absInt(ship[1]));
    return dx + dy;
}

test "part2" {
    const input = try cleanInput(testing.allocator, test_input);
    defer testing.allocator.free(input);
    testing.expectEqual(@intCast(u64, 286), try part2(input));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day12.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer alloc.free(input);

    warn("part1: {}\n", .{try part1(input)});
    warn("part2: {}\n", .{try part2(input)});
}
