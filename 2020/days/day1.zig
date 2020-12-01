const std = @import("std");
const common = @import("./common.zig");
const mem = std.mem;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const alloc = &arena.allocator;

pub fn cleanInput(allocator: *mem.Allocator, input: []const u8) !std.ArrayList(i32) {
    var nums = std.ArrayList(i32).init(allocator);

    var lines = mem.split(input, "\n");
    while (lines.next()) |line| {
        if (line.len != 0) {
            var i: i32 = try std.fmt.parseInt(i32, line, 10);
            try nums.append(i);
        }
    }
    return nums;
}

test "cleanInput" {
    var list = try cleanInput(alloc, "1721\n979\n366\n299\n675");
    std.testing.expectEqualSlices(
        i32,
        &[_]i32{ 1721, 979, 366, 299, 675 },
        list.items,
    );
}

pub fn first(nums: []i32) i32 {
    for (nums) |a| {
        for (nums) |b| {
            if (a != b and a + b == 2020) {
                return a * b;
            }
        }
    }
    return 0;
}

test "first" {
    var list = try cleanInput(alloc, "1721\n979\n366\n299\n675");
    std.testing.expectEqual(@intCast(i32, 514579), first(list.items));
}

pub fn second(nums: []i32) i32 {
    for (nums) |a| {
        for (nums) |b| {
            for (nums) |c| {
                if (a != b and b != c and a + b + c == 2020) {
                    return a * b * c;
                }
            }
        }
    }
    return 0;
}

test "second" {
    var list = try cleanInput(alloc, "1721\n979\n366\n299\n675");
    std.testing.expectEqual(@intCast(i32, 241861950), second(list.items));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day1.txt");
    defer alloc.free(file);
    const nums = try cleanInput(alloc, file);
    defer nums.deinit();

    const first_answer = first(nums.items);
    std.debug.warn("first: {}\n", .{first_answer});

    const second_answer = second(nums.items);
    std.debug.warn("second: {}\n", .{second_answer});
}
