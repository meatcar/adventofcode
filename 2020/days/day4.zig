const std = @import("std");
const common = @import("./common.zig");
const testing = std.testing;
const mem = std.mem;
const warn = std.debug.warn;
const parseInt = std.fmt.parseInt;

const alloc = std.heap.page_allocator;

const Field = struct { key: []const u8, val: []const u8 };

const required_fields = [_][]const u8{
    "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid",
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !std.ArrayList([]Field) {
    var input = std.ArrayList([]Field).init(allocator);

    var lines = mem.split(file, "\n\n");
    while (lines.next()) |line| {
        var fields = std.ArrayList(Field).init(allocator);
        var raw_fields = mem.tokenize(line, " \n");
        while (raw_fields.next()) |raw_field| {
            var field = mem.tokenize(raw_field, ":");
            const key = field.next().?;
            const val = field.next().?;
            for (required_fields) |f| {
                if (mem.eql(u8, key, f)) {
                    try fields.append(Field{ .key = key, .val = val });
                }
            }
        }
        try input.append(fields.items);
    }
    return input;
}

test "cleanInput" {
    const input = try cleanInput(alloc,
        \\ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
        \\byr:1937 iyr:2017 cid:147 hgt:183cm
        \\
        \\iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
        \\hcl:#cfa07d byr:1929
    );
    const true_input = [2][]const Field{
        &[_]Field{
            Field{ .key = "ecl", .val = "gry" },
            Field{ .key = "pid", .val = "860033327" },
            Field{ .key = "eyr", .val = "2020" },
            Field{ .key = "hcl", .val = "#fffffd" },
            Field{ .key = "byr", .val = "1937" },
            Field{ .key = "iyr", .val = "2017" },
            Field{ .key = "cid", .val = "147" },
            Field{ .key = "hgt", .val = "183cm" },
        },
        &[_]Field{
            Field{ .key = "iyr", .val = "2013" },
            Field{ .key = "ecl", .val = "amb" },
            Field{ .key = "cid", .val = "350" },
            Field{ .key = "eyr", .val = "2013" },
            Field{ .key = "pid", .val = "028048884" },
            Field{ .key = "hcl", .val = "#cfa07d" },
            Field{ .key = "byr", .val = "1929" },
        },
    };
    var i: usize = 0;
    var j: usize = 0;
    while (i < true_input.len) : (i += 1) {
        while (j < true_input.len) : (j += 1) {
            testing.expectEqualSlices(
                u8,
                true_input[i][j].key,
                input.items[i][j].key,
            );
            testing.expectEqualSlices(
                u8,
                true_input[i][j].val,
                input.items[i][j].val,
            );
        }

        i += 1;
    }
}

pub fn part1(docs: [][]Field) i64 {
    var valid: i64 = 0;
    for (docs) |fields| {
        if (fields.len >= required_fields.len) valid += 1;
    }
    return valid;
}

test "part1" {
    var input = try cleanInput(alloc,
        \\ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
        \\byr:1937 iyr:2017 cid:147 hgt:183cm
        \\
        \\iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
        \\hcl:#cfa07d byr:1929
        \\
        \\hcl:#ae17e1 iyr:2013
        \\eyr:2024
        \\ecl:brn pid:760753108 byr:1931
        \\hgt:179cm
        \\
        \\hcl:#cfa07d eyr:2025 pid:166559648
        \\iyr:2011 ecl:brn hgt:59in
    );
    testing.expectEqual(@intCast(i64, 2), part1(input.items));
}

pub fn between(comptime T: type, a: T, low: T, high: T) bool {
    return a >= low and a <= high;
}
test "between" {
    testing.expect(between(u8, 'b', 'a', 'c'));
    testing.expect(between(u8, 'a', 'a', 'c'));
    testing.expect(between(u8, 'c', 'a', 'c'));
}

pub fn isValidField(field: Field) bool {
    const key = field.key;
    const val = field.val;
    if (mem.eql(u8, key, "byr")) {
        const i = parseInt(i64, val, 10) catch return false;
        return between(i64, i, 1920, 2002);
    } else if (mem.eql(u8, key, "iyr")) {
        const i = parseInt(i64, val, 10) catch return false;
        return between(i64, i, 2010, 2020);
    } else if (mem.eql(u8, key, "eyr")) {
        const i = parseInt(i64, val, 10) catch return false;
        return between(i64, i, 2020, 2030);
    } else if (mem.eql(u8, key, "hgt")) {
        const i = parseInt(i64, val[0 .. val.len - 2], 10) catch return false;
        if (mem.endsWith(u8, val, "cm")) {
            return between(i64, i, 150, 193);
        } else if (mem.endsWith(u8, val, "in")) {
            return between(i64, i, 59, 76);
        } else return false;
    } else if (mem.eql(u8, key, "hcl")) {
        if (val.len != 7 or val[0] != '#') return false;
        for (val[1..7]) |c| {
            if (!(between(u8, c, '0', '9') or between(u8, c, 'a', 'f'))) return false;
        }
        return true;
    } else if (mem.eql(u8, key, "ecl")) {
        const colors = [_][]const u8{
            "amb", "blu", "brn", "gry", "grn", "hzl", "oth",
        };
        for (colors) |color| {
            if (mem.eql(u8, val, color)) {
                return true;
            }
        }
        return false;
    } else if (mem.eql(u8, key, "pid")) {
        if (val.len != 9) return false;
        for (val) |c| {
            if (!between(u8, c, '0', '9')) return false;
        }
        return true;
    }
    return false;
}

test "isValidField" {
    testing.expect(isValidField(Field{ .key = "byr", .val = "2002" }));
    testing.expect(!isValidField(Field{ .key = "byr", .val = "2003" }));

    testing.expect(isValidField(Field{ .key = "hgt", .val = "60in" }));
    testing.expect(isValidField(Field{ .key = "hgt", .val = "190cm" }));
    testing.expect(!isValidField(Field{ .key = "hgt", .val = "190in" }));
    testing.expect(!isValidField(Field{ .key = "hgt", .val = "190" }));

    testing.expect(isValidField(Field{ .key = "hcl", .val = "#123abc" }));
    testing.expect(!isValidField(Field{ .key = "hcl", .val = "#123abz" }));
    testing.expect(!isValidField(Field{ .key = "hcl", .val = "123abz" }));

    testing.expect(isValidField(Field{ .key = "ecl", .val = "brn" }));
    testing.expect(!isValidField(Field{ .key = "ecl", .val = "wat" }));

    testing.expect(isValidField(Field{ .key = "pid", .val = "000000001" }));
    testing.expect(!isValidField(Field{ .key = "pid", .val = "0123456789" }));
    testing.expect(!isValidField(Field{ .key = "pid", .val = "013" }));
}

pub fn part2(docs: [][]Field) i64 {
    var valid_docs: i64 = 0;
    for (docs) |fields| {
        var valid: i64 = 0;
        for (fields) |field| {
            if (isFieldValid(field)) valid += 1;
        }
        if (fields.len >= required_fields.len and fields.len == valid)
            valid_docs += 1;
    }
    return valid_docs;
}

test "part2" {
    var input = try cleanInput(alloc,
        \\eyr:1972 cid:100
        \\hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926
        \\
        \\iyr:2019
        \\hcl:#602927 eyr:1967 hgt:170cm
        \\ecl:grn pid:012533040 byr:1946
        \\
        \\hcl:dab227 iyr:2012
        \\ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277
        \\
        \\hgt:59cm ecl:zzz
        \\eyr:2038 hcl:74454a iyr:2023
        \\pid:3556412378 byr:2007
    );
    testing.expectEqual(@intCast(i64, 0), part2(input.items));

    input = try cleanInput(alloc,
        \\pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
        \\hcl:#623a2f
        \\
        \\eyr:2029 ecl:blu cid:129 byr:1989
        \\iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm
        \\
        \\hcl:#888785
        \\hgt:164cm byr:2001 iyr:2015 cid:88
        \\pid:545766238 ecl:hzl
        \\eyr:2022
        \\
        \\iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021
        \\pid:093154719
    );
    testing.expectEqual(@intCast(i64, 4), part2(input.items));
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day4.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.deinit();

    const part1_answer = part1(input.items);
    std.debug.warn("part1: {}\n", .{part1_answer});

    const part2_answer = part2(input.items);
    std.debug.warn("part2: {}\n", .{part2_answer});
}
