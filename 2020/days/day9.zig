usingnamespace @import("./common.zig");

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !ArrayList(u64) {
    var input = ArrayList(u64).init(allocator);

    var line_it = mem.tokenize(file, "\n");
    while (line_it.next()) |line| {
        try input.append(try parseInt(u64, line, 10));
    }

    return input;
}

const test_input =
    \\35
    \\20
    \\15
    \\25
    \\47
    \\40
    \\62
    \\55
    \\65
    \\95
    \\102
    \\117
    \\150
    \\182
    \\127
    \\219
    \\299
    \\277
    \\309
    \\576
;

test "cleanInput" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();

    var answer = [_]u64{
        35,  20,  15,  25,  47,  40,  62,  55,  65,  95,
        102, 117, 150, 182, 127, 219, 299, 277, 309, 576,
    };

    testing.expectEqualSlices(u64, answer[0..], input.items);
}

fn findInvalid(input: []u64, preamble_size: usize) u64 {
    var window: []u64 = undefined;

    for (input) |n, i| {
        if (i < preamble_size) continue;

        window = input[i - preamble_size .. i];

        var valid = false;
        for (window) |a, j| {
            for (window) |b, k| {
                if (j == k) continue;
                if (n == a + b) valid = true;
            }
        }
        if (!valid) return n;
    }

    return 0;
}

test "findInvalid" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();
    testing.expectEqual(@intCast(u64, 127), findInvalid(input.items, 5));
}

pub fn first(allocator: *mem.Allocator, input: ArrayList(u64)) !u64 {
    return findInvalid(input.items, 25);
}

pub fn second(allocator: *mem.Allocator, input: ArrayList(u64)) !u64 {
    const n = findInvalid(input.items, 25);

    var i: usize = 0;
    while (i < input.items.len) : (i += 1) {
        var j: usize = i + 1;
        while (i + j < input.items.len) : (j += 1) {
            const slice = input.items[i..j];

            var sum: u64 = 0;
            for (slice) |s| sum += s;

            if (sum > n) {
                break;
            } else if (sum == n) {
                return mem.max(u64, slice) + mem.min(u64, slice);
            }
        }
    }
    return 0;
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day9.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const first_answer = try first(alloc, input);
    warn("first: {}\n", .{first_answer});

    const second_answer = try second(alloc, input);
    warn("second: {}\n", .{second_answer});
}
