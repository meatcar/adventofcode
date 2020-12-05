usingnamespace @import("./common.zig");

const Policy = struct {
    max: i64,
    min: i64,
    char: i64,
    pass: []const u8,
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !std.ArrayList(Policy) {
    var input = std.ArrayList(Policy).init(allocator);

    var lines = mem.tokenize(file, "\n");
    while (lines.next()) |line| {
        var sections = mem.tokenize(line, " ");
        var limits = mem.tokenize(sections.next().?, "-");
        var item = Policy{
            .min = try parseInt(i64, limits.next().?, 10),
            .max = try parseInt(i64, limits.next().?, 10),
            .char = sections.next().?[0],
            .pass = sections.next().?,
        };
        try input.append(item);
    }
    return input;
}

test "cleanInput" {
    var input = try cleanInput(alloc,
        \\1-3 a: abcde
        \\1-3 b: cdefg
        \\2-9 c: ccccccccc
    );
    var true_input = [_]Policy{
        Policy{ .min = 1, .max = 3, .char = 'a', .pass = "abcde" },
        Policy{ .min = 1, .max = 3, .char = 'b', .pass = "cdefg" },
        Policy{ .min = 2, .max = 9, .char = 'c', .pass = "ccccccccc" },
    };
    var i: usize = 0;
    while (i < true_input.len) {
        testing.expectEqual(true_input[i].min, input.items[i].min);
        testing.expectEqual(true_input[i].max, input.items[i].max);
        testing.expectEqual(true_input[i].char, input.items[i].char);
        testing.expectEqualSlices(u8, true_input[i].pass, input.items[i].pass);
        i += 1;
    }
}

pub fn part1(items: []Policy) i64 {
    var valid: i64 = 0;
    for (items) |item| {
        var letters = [_]u8{0} ** 26;
        for (item.pass) |c| {
            letters[c - 97] += 1;
        }
        var count = letters[@intCast(usize, item.char - 97)];
        if (count >= item.min and count <= item.max) {
            valid += 1;
        }
    }
    return valid;
}

test "part1" {
    var list = try cleanInput(alloc,
        \\1-3 a: abcde
        \\1-3 b: cdefg
        \\2-9 c: ccccccccc
    );
    testing.expectEqual(@intCast(i64, 2), part1(list.items));
}

pub fn part2(items: []Policy) i64 {
    var valid: i64 = 0;
    for (items) |item| {
        var first = item.pass[@intCast(usize, item.min) - 1];
        var second = item.pass[@intCast(usize, item.max) - 1];
        if (first != second and (first == item.char or second == item.char)) {
            valid += 1;
        }
    }
    return valid;
}

test "part2" {
    var list = try cleanInput(alloc,
        \\1-3 a: abcde
        \\1-3 b: cdefg
        \\2-9 c: ccccccccc
    );
    testing.expectEqual(@intCast(i64, 1), part2(list.items));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day2.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const part1_answer = part1(input.items);
    warn("part1: {}\n", .{part1_answer});

    const part2_answer = part2(input.items);
    warn("part2: {}\n", .{part2_answer});
}
