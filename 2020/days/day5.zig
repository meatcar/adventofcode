usingnamespace @import("./common.zig");

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !std.ArrayList(i64) {
    var input = std.ArrayList(i64).init(allocator);

    var lines = mem.tokenize(file, "\n");
    while (lines.next()) |line| {
        var row_str = [_]u8{'0'} ** 7;
        var col_str = [_]u8{'0'} ** 3;

        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            if (i < 7 and line[i] == 'B') {
                row_str[i] = '1';
            } else if (i >= 7 and line[i] == 'R') {
                col_str[i - 7] = '1';
            }
        }

        const row: i64 = try parseInt(u8, row_str[0..], 2);
        const col: i64 = try parseInt(u8, col_str[0..], 2);

        // warn("{} => {}({}) {}({})\n", .{line, row_str, row, col_str, col});

        try input.append(row * 8 + col);
    }
    return input;
}

test "cleanInput" {
    const list = try cleanInput(alloc,
        \\BFFFBBFRRR
        \\FFFBBBFRRR
        \\BBFFBBFRLL
    );
    defer list.deinit();
    const answer = [_]i64{ 567, 119, 820 };
    testing.expectEqualSlices(i64, &answer, list.items);
}

pub fn first(input: []const i64) i64 {
    return mem.max(i64, input);
}

test "first" {
    const list = try cleanInput(alloc,
        \\BFFFBBFRRR
        \\FFFBBBFRRR
        \\BBFFBBFRLL
    );
    defer list.deinit();
    testing.expectEqual(@intCast(i64, 820), first(list.items));
}

pub fn second(input: []const i64) i64 {
    var sorted = mem.dupe(alloc, i64, input) catch return -1;
    std.sort.sort(i64, sorted, std.sort.asc(i64));

    var prev: i64 = sorted[0];
    for (sorted) |id| {
        if (id - prev > 1) return id - 1;
        prev = id;
    }
    return -1;
}

test "second" {
    var items = [_]i64{
        0,  1,  2,  3,  4,  5,  6,  7,
        8,  10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23,
    };
    testing.expectEqual(@intCast(i64, 9), second(items[0..]));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day5.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const first_answer = first(input.items);
    warn("first: {}\n", .{first_answer});

    const second_answer = second(input.items);
    warn("second: {}\n", .{second_answer});
}
