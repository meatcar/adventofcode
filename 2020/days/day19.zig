usingnamespace @import("./common.zig");

const Elem = union(enum) {
    Rule: usize,
    Str: []const u8,
};
const Rule = [][]Elem;

const Input = struct {
    const Self = @This();

    rules: []Rule,
    msgs: [][]const u8,
    allocator: *mem.Allocator,

    pub fn init(allocator: *mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .rules = undefined,
            .msgs = undefined,
        };
    }

    pub fn deinit(self: Self) void {
        for (self.rules) |ors, i| {
            if (ors.len == 0) continue;
            for (ors) |rules| {
                self.allocator.free(rules);
            }
            self.allocator.free(ors);
        }
        self.allocator.free(self.rules);
        self.allocator.free(self.msgs);
    }
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !Input {
    var input: Input = try Input.init(allocator);

    var file_it = mem.split(file, "\n\n");
    var rules_it = mem.tokenize(file_it.next().?, "\n");
    var msgs_it = mem.tokenize(file_it.next().?, "\n");

    var rule_map = std.AutoHashMap(usize, Rule).init(allocator);
    defer rule_map.deinit();
    var msgs = ArrayList([]const u8).init(allocator);
    defer msgs.deinit();

    while (rules_it.next()) |rule_str| {
        var rule_it = mem.tokenize(rule_str, ": ");

        var i = try parseInt(usize, rule_it.next().?, 10);

        var or_list = ArrayList([]Elem).init(allocator);
        var rule_list = ArrayList(Elem).init(allocator);
        while (rule_it.next()) |str| {
            if (mem.eql(u8, str, "\"a\"")) {
                try rule_list.append(Elem{ .Str = "a" });
            } else if (mem.eql(u8, str, "\"b\"")) {
                try rule_list.append(Elem{ .Str = "b" });
            } else if (mem.eql(u8, str, "|")) {
                try or_list.append(rule_list.toOwnedSlice());
                // rule_list is empty now
            } else {
                try rule_list.append(Elem{ .Rule = try parseInt(usize, str, 10) });
            }
        }
        try or_list.append(rule_list.toOwnedSlice());
        _ = try rule_map.put(i, or_list.toOwnedSlice());
    }

    while (msgs_it.next()) |msg_str| {
        try msgs.append(msg_str);
    }

    var max_rule: usize = 0;
    var rule_map_it = rule_map.iterator();
    while (rule_map_it.next()) |kv| {
        if (kv.key > max_rule) max_rule = kv.key;
    }

    var rules = try allocator.alloc(Rule, max_rule + 1);
    mem.set(Rule, rules, &[0][]Elem{});
    rule_map_it = rule_map.iterator();
    while (rule_map_it.next()) |kv| {
        rules[kv.key] = kv.value;
    }

    input.rules = rules;
    input.msgs = msgs.toOwnedSlice();
    return input;
}

const test_input =
    \\0: 4 1 5
    \\1: 2 3 | 3 2
    \\2: 4 4 | 5 5
    \\3: 4 5 | 5 4
    \\4: "a"
    \\5: "b"
    \\
    \\ababbb
    \\bababa
    \\abbbab
    \\aaabbb
    \\aaaabbb
;

test "cleanInput" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, test_input);
    defer input.deinit();

    testing.expectEqualSlices(Elem, &[_]Elem{
        Elem{ .Rule = 4 },
        Elem{ .Rule = 1 },
        Elem{ .Rule = 5 },
    }, input.rules[0][0]);

    testing.expectEqualSlices(Elem, &[_]Elem{
        Elem{ .Rule = 2 },
        Elem{ .Rule = 3 },
    }, input.rules[1][0]);
    testing.expectEqualSlices(Elem, &[_]Elem{
        Elem{ .Rule = 3 },
        Elem{ .Rule = 2 },
    }, input.rules[1][1]);

    testing.expectEqualSlices(u8, "a", input.rules[4][0][0].Str);
}

fn validateRecursively(str: []const u8, rule_i: usize, rules: []Rule) []const u8 {
    const rule = rules[rule_i];

    if (rule.len == 1 and rule[0][0] == .Str) {
        if (mem.startsWith(u8, str, rule[0][0].Str)) {
            return str[rule[0][0].Str.len..];
        } else {
            return str;
        }
    }

    var remainder: []const u8 = undefined;
    var ok_count: usize = undefined;
    outer: for (rule) |branch| {
        remainder = str;
        ok_count = 0;
        for (branch) |e| {
            var new_remainder = validateRecursively(remainder, e.Rule, rules);
            if (remainder.len == new_remainder.len) {
                break;
            }
            ok_count += 1;
            remainder = new_remainder;
            if (remainder.len == 0) break;
        }
        if (ok_count == branch.len) {
            break;
        } else {
            remainder = str;
        }
    }
    return remainder;
}

fn validate(str: []const u8, rules: []Rule) bool {
    var remainder = validateRecursively(str, 0, rules);
    return remainder.len == 0;
}

pub fn part1(allocator: *mem.Allocator, input: Input) !u64 {
    var count: u64 = 0;
    for (input.msgs) |msg| {
        if (validate(msg, input.rules)) count += 1;
    }

    return count;
}

test "part1" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 2), try part1(allocator, input));
    input.deinit();
}

fn validate2(str: []const u8, rules: []Rule) bool {
    // rule 8 is 1 or more rule 42s.
    //
    // rule 11 is n 42s followed by n 31s.
    //
    // Rule 0 is rule 8 followed by rule 11, in both the test and the final input.
    //
    // The validation from part 1 is greedy and doesn't backtrack. So it
    // consumes all the 42s with rule 8, then complains about the 31s that follow.
    // Lets unroll rule 0 manually.
    var num_42s: u64 = 0;
    var num_31s: u64 = 0;

    var remainder = str;
    while (true) {
        var new_remainder = validateRecursively(remainder, 42, rules);
        if (remainder.len == new_remainder.len) break;
        num_42s += 1;
        remainder = new_remainder;
    }

    while (true) {
        var new_remainder = validateRecursively(remainder, 31, rules);
        if (remainder.len == new_remainder.len) break;
        num_31s += 1;
        remainder = new_remainder;
    }

    return remainder.len == 0 and num_42s > 1 and num_31s > 0 and num_42s > num_31s;
}

pub fn part2(allocator: *mem.Allocator, input: Input) !u64 {
    var count: u64 = 0;
    for (input.msgs) |msg| {
        if (validate2(msg, input.rules)) count += 1;
    }

    return count;
}

test "part2" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator,
        \\42: 9 14 | 10 1
        \\9: 14 27 | 1 26
        \\10: 23 14 | 28 1
        \\1: "a"
        \\11: 42 31
        \\5: 1 14 | 15 1
        \\19: 14 1 | 14 14
        \\12: 24 14 | 19 1
        \\16: 15 1 | 14 14
        \\31: 14 17 | 1 13
        \\6: 14 14 | 1 14
        \\2: 1 24 | 14 4
        \\0: 8 11
        \\13: 14 3 | 1 12
        \\15: 1 | 14
        \\17: 14 2 | 1 7
        \\23: 25 1 | 22 14
        \\28: 16 1
        \\4: 1 1
        \\20: 14 14 | 1 15
        \\3: 5 14 | 16 1
        \\27: 1 6 | 14 18
        \\14: "b"
        \\21: 14 1 | 1 14
        \\25: 1 1 | 1 14
        \\22: 14 14
        \\8: 42
        \\26: 14 22 | 1 20
        \\18: 15 15
        \\7: 14 5 | 1 21
        \\24: 14 1
        \\
        \\abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
        \\bbabbbbaabaabba
        \\babbbbaabbbbbabbbbbbaabaaabaaa
        \\aaabbbbbbaaaabaababaabababbabaaabbababababaaa
        \\bbbbbbbaaaabbbbaaabbabaaa
        \\bbbababbbbaaaaaaaabbababaaababaabab
        \\ababaaaaaabaaab
        \\ababaaaaabbbaba
        \\baabbaaaabbaaaababbaababb
        \\abbbbabbbbaaaababbbbbbaaaababb
        \\aaaaabbaabaaaaababaa
        \\aaaabbaaaabbaaa
        \\aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
        \\babaaabbbaaabaababbaabababaaab
        \\aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
    );
    // testing.expectEqual(@intCast(u64, 3), try part1(allocator, input));
    testing.expectEqual(@intCast(u64, 12), try part2(allocator, input));
    input.deinit();
}

pub fn main() !void {
    const allocator = default_allocator;
    const file = try common.readFile(alloc, "inputs/day19.txt");
    defer alloc.free(file);
    const input = try cleanInput(allocator, file);
    defer input.deinit();

    warn("part1: {}\n", .{try part1(allocator, input)});
    warn("part2: {}\n", .{try part2(allocator, input)});
}
