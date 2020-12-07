usingnamespace @import("./common.zig");

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !std.ArrayList([][]const u8) {
    var input = std.ArrayList([][]const u8).init(allocator);

    var groups = mem.split(file, "\n\n");
    while (groups.next()) |group| {
        var input_group = std.ArrayList([]const u8).init(allocator);
        var answers = mem.tokenize(group, "\n");
        while (answers.next()) |answer| {
            try input_group.append(answer);
        }
        try input.append(input_group.items);
    }
    return input;
}

const test_input =
    \\abc
    \\
    \\a
    \\b
    \\c
    \\
    \\ab
    \\ac
    \\
    \\a
    \\a
    \\a
    \\a
    \\
    \\b
;

test "cleanInput" {
    const list = try cleanInput(alloc, test_input);
    defer list.deinit();
    const answer = [_][]const []const u8{
        &[_][]const u8{
            "abc",
        },
        &[_][]const u8{
            "a",
            "b",
            "c",
        },
        &[_][]const u8{
            "ab",
            "ac",
        },
        &[_][]const u8{
            "a",
            "a",
            "a",
            "a",
        },
        &[_][]const u8{
            "b",
        },
    };
    for (answer) |group, g| {
        for (group) |member, m| {
            testing.expectEqualSlices(u8, member, list.items[g][m]);
        }
    }
}

pub fn first(input: [][][]const u8) i64 {
    var sum: i64 = 0;
    for (input) |group, g| {
        var questions = [_]bool{false} ** 26;
        for (group) |member, m| {
            for (member) |c| {
                const answer = &questions[@intCast(usize, c - 97)];
                if (!answer.*) {
                    sum += 1;
                    answer.* = true;
                }
            }
        }
    }
    return sum;
}

test "first" {
    const list = try cleanInput(alloc, test_input);
    defer list.deinit();
    testing.expectEqual(@intCast(i64, 11), first(list.items));
}

pub fn second(input: [][][]const u8) i64 {
    var sum: i64 = 0;
    for (input) |group, g| {
        var questions = [_]usize{0} ** 26;
        for (group) |member, m| {
            for (member) |c| {
                questions[@intCast(usize, c - 97)] += 1;
            }
        }
        for (questions) |q| {
            if (q == group.len) {
                sum += 1;
            }
        }
    }
    return sum;
}

test "second" {
    const list = try cleanInput(alloc, test_input);
    defer list.deinit();
    testing.expectEqual(@intCast(i64, 6), second(list.items));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day6.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const first_answer = first(input.items);
    warn("first: {}\n", .{first_answer});

    const second_answer = second(input.items);
    warn("second: {}\n", .{second_answer});
}
