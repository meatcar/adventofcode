const std = @import("std");
const common = @import("./common.zig");
const mem = std.mem;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const alloc = &arena.allocator;

const Policy = struct {
    max: i64,
    min: i64,
    char: i64,
    pass: []const u8,
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !std.ArrayList([]const u8) {
    var input = std.ArrayList([]const u8).init(allocator);

    var lines = mem.tokenize(file, "\n");
    while (lines.next()) |line| {
        try input.append(line);
    }
    return input;
}

test "cleanInput" {
    var input = try cleanInput(alloc,
        \\..##.......
        \\#...#...#..
        \\.#....#..#.
        \\..#.#...#.#
        \\.#...##..#.
        \\..#.##.....
        \\.#.#.#....#
        \\.#........#
        \\#.##...#...
        \\#...##....#
        \\.#..#...#.#
    );
    var true_input = [_][]const u8{
        "..##.......",
        "#...#...#..",
        ".#....#..#.",
        "..#.#...#.#",
        ".#...##..#.",
        "..#.##.....",
        ".#.#.#....#",
        ".#........#",
        "#.##...#...",
        "#...##....#",
        ".#..#...#.#",
    };
    var i: usize = 1;
    while (i < true_input.len) {
        std.testing.expectEqualSlices(u8, true_input[i], input.items[i]);
        i += 1;
    }
}

pub fn checkSlope(map: [][]const u8, delta_x: usize, delta_y: usize) i64 {
    var x: usize = 0;
    var y: usize = 0;
    var tree: i64 = 0;
    while (y < map.len) {
        if (map[y][x] == '#') {
            tree += 1;
        }
        x = @mod(x + delta_x, map[0].len);
        y += delta_y;
    }
    return tree;
}

pub fn part1(items: [][]const u8) i64 {
    return checkSlope(items, 3, 1);
}

test "part1" {
    var input = try cleanInput(alloc,
        \\..##.......
        \\#...#...#..
        \\.#....#..#.
        \\..#.#...#.#
        \\.#...##..#.
        \\..#.##.....
        \\.#.#.#....#
        \\.#........#
        \\#.##...#...
        \\#...##....#
        \\.#..#...#.#
    );
    std.testing.expectEqual(@intCast(i64, 7), part1(input.items));
}

pub fn part2(items: [][]const u8) i64 {
    const slopes = [_][2]usize{
        [_]usize{ 1, 1 },
        [_]usize{ 3, 1 },
        [_]usize{ 5, 1 },
        [_]usize{ 7, 1 },
        [_]usize{ 1, 2 },
    };
    var trees: i64 = 1;
    for (slopes) |slope| {
        const count = checkSlope(items, slope[0], slope[1]);
        trees *= count;
    }
    return trees;
}

test "part2" {
    var input = try cleanInput(alloc,
        \\..##.......
        \\#...#...#..
        \\.#....#..#.
        \\..#.#...#.#
        \\.#...##..#.
        \\..#.##.....
        \\.#.#.#....#
        \\.#........#
        \\#.##...#...
        \\#...##....#
        \\.#..#...#.#
    );
    std.testing.expectEqual(@intCast(i64, 336), part2(input.items));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day3.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const part1_answer = part1(input.items);
    std.debug.warn("part1: {}\n", .{part1_answer});

    const part2_answer = part2(input.items);
    std.debug.warn("part2: {}\n", .{part2_answer});
}
