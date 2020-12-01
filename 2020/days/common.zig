const std = @import("std");

pub fn readFile(allocator: *std.mem.Allocator, path: []const u8) ![]const u8 {
    const max_bytes = 10 * 1024 * 1024;
    var file = try std.fs.cwd().readFileAlloc(allocator, path, max_bytes);
    return file;
}

