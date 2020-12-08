usingnamespace @import("./common.zig");

const StringHashMap = std.StringHashMap;

const Count = struct {
    n: u64,
    colour: []const u8,
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !StringHashMap(ArrayList(Count)) {
    var input = std.StringHashMap(ArrayList(Count)).init(alloc);

    var lines = mem.tokenize(file, "\n");
    while (lines.next()) |line| {
        var rule = mem.split(line, " bags contain ");
        const color = rule.next().?;
        var insides = mem.split(rule.next().?, ", ");

        var contents = ArrayList(Count).init(alloc);

        while (insides.next()) |count| {
            if (mem.eql(u8, count, "no other bags.")) continue;

            const last_space = mem.lastIndexOf(u8, count, " ").?;
            const num = try parseInt(u64, count[0..1], 10);
            const inside_color = count[2..last_space];

            try contents.append(Count{ .n = num, .colour = inside_color });
        }
        _ = try input.put(color, contents);
    }
    return input;
}

const test_input =
    \\light red bags contain 1 bright white bag, 2 muted yellow bags.
    \\dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    \\bright white bags contain 1 shiny gold bag.
    \\muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    \\shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    \\dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    \\vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    \\faded blue bags contain no other bags.
    \\dotted black bags contain no other bags.
;

test "cleanInput" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();

    var answer = StringHashMap([]const Count).init(std.testing.allocator);
    _ = try answer.put("light red", &[_]Count{
        .{ .n = 1, .colour = "bright white" },
        .{ .n = 2, .colour = "muted yellow" },
    });
    _ = try answer.put("dark orange", &[_]Count{
        .{ .n = 3, .colour = "bright white" },
        .{ .n = 4, .colour = "muted yellow" },
    });
    _ = try answer.put("bright white", &[_]Count{
        .{ .n = 1, .colour = "shiny gold" },
    });
    _ = try answer.put("muted yellow", &[_]Count{
        .{ .n = 2, .colour = "shiny gold" },
        .{ .n = 9, .colour = "faded blue" },
    });
    _ = try answer.put("shiny gold", &[_]Count{
        .{ .n = 1, .colour = "dark olive" },
        .{ .n = 2, .colour = "vibrant plum" },
    });
    _ = try answer.put("dark olive", &[_]Count{
        .{ .n = 3, .colour = "faded blue" },
        .{ .n = 4, .colour = "dotted black" },
    });
    _ = try answer.put("vibrant plum", &[_]Count{
        .{ .n = 5, .colour = "faded blue" },
        .{ .n = 6, .colour = "dotted black" },
    });
    _ = try answer.put("faded blue", &[0]Count{});
    _ = try answer.put("dotted black", &[0]Count{});
    defer answer.deinit();

    var it = answer.iterator();
    while (it.next()) |kv| {
        const input_kv = input.get(kv.key).?;
        for (kv.value) |count, i| {
            const input_count = input_kv.value.items[i];
            testing.expectEqual(count.n, input_count.n);
            testing.expectEqualSlices(u8, count.colour, input_count.colour);
        }
    }
}

pub fn first(allocator: *mem.Allocator, input: StringHashMap(ArrayList(Count))) !i64 {
    var parent_map = StringHashMap(ArrayList([]const u8)).init(allocator);

    var it = input.iterator();
    while (it.next()) |parent| {
        for (parent.value.items) |count| {
            var list: ArrayList([]const u8) = undefined;
            if (!parent_map.contains(count.colour)) {
                list = ArrayList([]const u8).init(allocator);
            } else {
                list = parent_map.getValue(count.colour).?;
            }
            try list.append(parent.key);
            _ = try parent_map.put(count.colour, list);
        }
    }
    defer parent_map.deinit();

    const bag = "shiny gold";

    var queued = std.BufSet.init(allocator);
    defer queued.deinit();

    var q = std.TailQueue([]const u8).init();

    q.append(try q.createNode(bag, allocator));
    try queued.put(bag);

    while (q.pop()) |node| {
        defer q.destroyNode(node, allocator);

        try queued.put(node.data);

        const children = parent_map.getValue(node.data) orelse continue;
        for (children.items) |child| {
            if (queued.exists(child)) continue;
            q.append(try q.createNode(child, allocator));
        }
    }

    var cleanup_it = parent_map.iterator();
    while (cleanup_it.next()) |next| {
        next.value.deinit();
    }
    return @intCast(i64, queued.count() - 1);
}

test "first" {
    const input = try cleanInput(std.testing.allocator, test_input);
    defer input.deinit();
    testing.expectEqual(@intCast(i64, 4), try first(std.testing.allocator, input));
}

pub fn second(allocator: *mem.Allocator, input: StringHashMap(ArrayList(Count))) !u64 {
    const bag = "shiny gold";
    var totals = StringHashMap(u64).init(allocator);
    defer totals.deinit();

    var q = std.TailQueue([]const u8).init();
    q.append(try q.createNode(bag, allocator));
    while (q.pop()) |node| {
        defer q.destroyNode(node, allocator);

        if (totals.contains(node.data)) continue;

        const children = input.getValue(node.data).?;

        var all_children_totaled = true;
        var total: u64 = 0;
        for (children.items) |count| {
            const child_total: u64 = totals.getValue(count.colour) orelse {
                all_children_totaled = false;
                break;
            };
            total += count.n * (child_total + 1);
        }

        if (all_children_totaled) {
            _ = try totals.put(node.data, total);
            continue;
        }

        q.append(try q.createNode(node.data, allocator));
        for (children.items) |count| {
            q.append(try q.createNode(count.colour, allocator));
        }
    }

    return totals.getValue(bag).?;
}

test "second" {
    const input1 = try cleanInput(std.testing.allocator, test_input);
    defer input1.deinit();
    testing.expectEqual(@intCast(u64, 32), try second(std.testing.allocator, input1));

    const input2 = try cleanInput(std.testing.allocator,
        \\shiny gold bags contain 2 dark red bags.
        \\dark red bags contain 2 dark orange bags.
        \\dark orange bags contain 2 dark yellow bags.
        \\dark yellow bags contain 2 dark green bags.
        \\dark green bags contain 2 dark blue bags.
        \\dark blue bags contain 2 dark violet bags.
        \\dark violet bags contain no other bags.
    );
    defer input2.deinit();
    testing.expectEqual(@intCast(u64, 126), try second(std.testing.allocator, input2));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day7.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const first_answer = try first(alloc, input);
    warn("first: {}\n", .{first_answer});

    const second_answer = try second(alloc, input);
    warn("second: {}\n", .{second_answer});
}
