pub const std = @import("std");
pub const common = @import("./common.zig");
pub const testing = std.testing;
pub const mem = std.mem;
pub const warn = std.debug.warn;
pub const parseInt = std.fmt.parseInt;
pub const alloc = std.heap.page_allocator;

pub fn readFile(allocator: *std.mem.Allocator, path: []const u8) ![]const u8 {
    const max_bytes = 10 * 1024 * 1024;
    var file = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
    return file;
}

