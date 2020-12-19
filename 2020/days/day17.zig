usingnamespace @import("./common.zig");

const Point = [4]i64;

const Input = struct {
    const Self = @This();

    /// map of points to active state
    points: std.ArrayList([2]i64),
    allocator: *mem.Allocator,

    pub fn init(allocator: *mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .points = ArrayList([2]i64).init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        self.points.deinit();
    }
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !Input {
    var input: Input = try Input.init(allocator);

    var file_it = mem.split(file, "\n");
    var y: i64 = 0;
    while (file_it.next()) |line| {
        var x: i64 = 0;
        for (line) |c| {
            const active = c == '#';
            if (active) try input.points.append([_]i64{ x, y });
            x += 1;
        }
        y += 1;
    }

    return input;
}

const test_input =
    \\.#.
    \\..#
    \\###
;

test "cleanInput" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, test_input);
    defer input.deinit();
    var answer = std.ArrayList([2]i64).init(allocator);
    try answer.append([_]i64{ 1, 0 });
    try answer.append([_]i64{ 2, 1 });
    try answer.append([_]i64{ 0, 2 });
    try answer.append([_]i64{ 1, 2 });
    try answer.append([_]i64{ 2, 2 });
    defer answer.deinit();

    for (answer.items) |n, i| {
        testing.expectEqualSlices(i64, &n, &input.points.items[i]);
    }
}

/// Return a list of all points in the 4-dimensional cube determined by min point and max point
fn makePoints(allocator: *mem.Allocator, min: Point, max: Point) ![]Point {
    var list = std.ArrayList(Point).init(allocator);

    try list.append(min);

    var i: usize = 0;
    while (i < min.len) : (i += 1) {
        var tmp = try std.ArrayList(Point).initCapacity(allocator, @intCast(usize, max[i] - min[i] + 1));
        defer tmp.deinit();

        for (list.items) |p| {
            var n = p[i] + 1;
            while (n <= max[i]) : (n += 1) {
                var new_p = p;
                new_p[i] = n;
                try tmp.append(new_p);
            }
        }
        try list.appendSlice(tmp.items);
    }

    return list.toOwnedSlice();
}

test "makePoints" {
    const allocator = testing.allocator;
    var points = try makePoints(allocator, Point{ 0, 0, 0, 0 }, Point{ 1, 0, 0, 0 });
    testing.expectEqualSlices(Point, &[_]Point{
        Point{ 0, 0, 0, 0 },
        Point{ 1, 0, 0, 0 },
    }, points);
    allocator.free(points);

    points = try makePoints(allocator, Point{ 0, 0, 0, 0 }, Point{ 0, 0, 1, 0 });
    testing.expectEqualSlices(Point, &[_]Point{
        Point{ 0, 0, 0, 0 },
        Point{ 0, 0, 1, 0 },
    }, points);
    allocator.free(points);
}

fn countAdjacentActive(allocator: *mem.Allocator, point: Point, grid: std.AutoHashMap(Point, bool)) !u64 {
    var adjacent: u64 = 0;
    var min = [_]i64{-1} ** 4;
    var max = [_]i64{1} ** 4;
    var neighbors = try makePoints(allocator, min, max);
    defer allocator.free(neighbors);
    for (neighbors) |p| {
        var all_zero = true;
        for (p) |n| {
            if (n != 0) {
                all_zero = false;
                break;
            }
        }
        if (all_zero) continue;

        var q = point;
        q[0] += p[0];
        q[1] += p[1];
        q[2] += p[2];
        q[3] += p[3];

        var active = grid.getValue(q);

        if (active != null and active.?) adjacent += 1;
    }

    return adjacent;
}

fn getMinMax(grid: std.AutoHashMap(Point, bool)) [2]Point {
    var min: Point = [_]i64{math.maxInt(i64)} ** 4;
    var max: Point = [_]i64{math.minInt(i64)} ** 4;

    var it = grid.iterator();
    while (it.next()) |kv| {
        for (kv.key) |n, i| {
            if (n <= min[i]) min[i] = n - 1;
            if (n >= max[i]) max[i] = n + 1;
        }
    }

    return [2]Point{ min, max };
}

fn printPoint(p: Point) void {
    for (p) |n| warn("{},", .{n});
}

fn runSixCycles(allocator: *mem.Allocator, input: Input, dimensions: usize) !u64 {
    var grid = std.AutoHashMap(Point, bool).init(allocator);
    for (input.points.items) |p|
        _ = try grid.put(Point{ p[0], p[1], 0, 0 }, true);

    var cycles: u8 = 0;
    while (cycles < 6) : (cycles += 1) {
        var new_grid = std.AutoHashMap(Point, bool).init(allocator);

        var min: Point = undefined;
        var max: Point = undefined;
        for (getMinMax(grid)) |n, i| {
            if (i == 0) min = n;
            if (i == 1) max = n;
        }

        // Hack, ignore the 4th dimension when needed
        if (dimensions == 3) {
            min[3] = 0;
            max[3] = 0;
        }

        var points = try makePoints(allocator, min, max);
        defer allocator.free(points);

        for (points) |p| {
            var value = grid.getValue(p) orelse false;
            var adjacent = try countAdjacentActive(allocator, p, grid);

            if (value and (adjacent == 2 or adjacent == 3)) {
                _ = try new_grid.put(p, true);
            } else if (!value and adjacent == 3) {
                _ = try new_grid.put(p, true);
            }
        }

        mem.swap(@TypeOf(grid), &grid, &new_grid);
        new_grid.deinit();
    }

    var it = grid.iterator();
    var total_active: u64 = 0;
    while (it.next()) |kv| {
        if (kv.value) total_active += 1;
    }
    grid.deinit();
    return total_active;
}

pub fn part1(allocator: *mem.Allocator, input: Input) !u64 {
    return runSixCycles(allocator, input, 3);
}

test "part1" {
    const allocator = default_allocator;
    var input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 112), try part1(allocator, input));
    input.deinit();
}

pub fn part2(allocator: *mem.Allocator, input: Input) !u64 {
    return runSixCycles(allocator, input, 4);
}

test "part2" {
    const allocator = default_allocator;
    var input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 848), try part2(allocator, input));
    input.deinit();
}

pub fn main() !void {
    const allocator = default_allocator;
    const file = try common.readFile(alloc, "inputs/day17.txt");
    defer alloc.free(file);
    const input = try cleanInput(allocator, file);
    defer input.deinit();

    warn("part1: {}\n", .{try part1(allocator, input)});
    warn("part2: {}\n", .{try part2(allocator, input)});
}
