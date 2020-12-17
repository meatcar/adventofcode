usingnamespace @import("./common.zig");

const Range = struct {
    min: u64,
    max: u64,
};

const Column = struct {
    name: []const u8,
    ranges: [2]Range,
};

const Input = struct {
    columns: []Column,
    my_ticket: []u64,
    tickets: [][]u64,

    pub fn free(self: Input, allocator: *mem.Allocator) void {
        allocator.free(self.columns);
        allocator.free(self.my_ticket);
        for (self.tickets) |t| allocator.free(t);
        allocator.free(self.tickets);
    }
};

pub fn cleanInput(allocator: *mem.Allocator, file: []const u8) !Input {
    // colons are used in two labels
    var num_columns: u64 = countOccurences(u8, file, ":") - 2;
    // commas are ticket column separators, so n columns = n-1 commas
    var num_tickets: u64 = countOccurences(u8, file, ",") / (num_columns - 1);

    var input: Input = Input{
        .columns = try allocator.alloc(Column, num_columns),
        .my_ticket = try allocator.alloc(u64, num_columns),
        .tickets = try allocator.alloc([]u64, num_tickets - 1),
    };
    for (input.tickets) |*ticket| ticket.* = try allocator.alloc(u64, num_columns);

    var file_it = mem.split(file, "\n\n");
    var columns_it = mem.tokenize(file_it.next().?, "\n");
    var my_ticket_it = mem.tokenize(file_it.next().?, "\n,");
    var tickets_it = mem.tokenize(file_it.next().?, "\n");

    // parse columns section
    for (input.columns) |*column| {
        const column_str = columns_it.next().?;

        const colon = mem.indexOf(u8, column_str, ":").?;
        column.name = column_str[0..colon];

        var col_it = mem.split(column_str[colon + 2 ..], " or ");
        for (column.ranges) |*range| {
            const range_str = col_it.next().?;

            const dash = mem.indexOf(u8, range_str, "-").?;
            range.min = try parseInt(u64, range_str[0..dash], 10);
            range.max = try parseInt(u64, range_str[dash + 1 ..], 10);
        }
    }

    // parse "your tickets" section
    _ = my_ticket_it.next(); // discard "your ticket:"
    for (input.my_ticket) |*n|
        n.* = try parseInt(u64, my_ticket_it.next().?, 10);

    // parse "nearby tickets" section
    _ = tickets_it.next(); // discard "nearby tickets:"
    for (input.tickets) |*ticket| {
        var ticket_it = mem.tokenize(tickets_it.next().?, ",");
        for (ticket.*) |*n|
            n.* = try parseInt(u64, ticket_it.next().?, 10);
    }

    return input;
}

const test_input =
    \\class: 1-3 or 5-7
    \\row: 6-11 or 33-44
    \\seat: 13-40 or 45-50
    \\
    \\your ticket:
    \\7,1,14
    \\
    \\nearby tickets:
    \\7,3,47
    \\40,4,50
    \\55,2,20
    \\38,6,12
;

test "cleanInput" {
    var input = try cleanInput(testing.allocator, test_input);
    defer input.free(testing.allocator);

    testing.expectEqualSlices(u8, "class", input.columns[0].name);
    testing.expectEqual(Range{ .min = 1, .max = 3 }, input.columns[0].ranges[0]);
    testing.expectEqual(Range{ .min = 5, .max = 7 }, input.columns[0].ranges[1]);
    testing.expectEqualSlices(u8, "row", input.columns[1].name);
    testing.expectEqual(Range{ .min = 6, .max = 11 }, input.columns[1].ranges[0]);
    testing.expectEqual(Range{ .min = 33, .max = 44 }, input.columns[1].ranges[1]);
    testing.expectEqualSlices(u8, "seat", input.columns[2].name);
    testing.expectEqual(Range{ .min = 13, .max = 40 }, input.columns[2].ranges[0]);
    testing.expectEqual(Range{ .min = 45, .max = 50 }, input.columns[2].ranges[1]);

    testing.expectEqualSlices(u64, &[_]u64{ 7, 1, 14 }, input.my_ticket);

    testing.expectEqualSlices(u64, &[_]u64{ 7, 3, 47 }, input.tickets[0]);
    testing.expectEqualSlices(u64, &[_]u64{ 40, 4, 50 }, input.tickets[1]);
    testing.expectEqualSlices(u64, &[_]u64{ 55, 2, 20 }, input.tickets[2]);
    testing.expectEqualSlices(u64, &[_]u64{ 38, 6, 12 }, input.tickets[3]);
}

/// Return true if any column rules passes for n
fn validColumn(n: u64, column: Column) bool {
    const r1 = column.ranges[0];
    const r2 = column.ranges[1];
    return (n >= r1.min and n <= r1.max) or (n >= r2.min and n <= r2.max);
}

/// Return true if ticket is valid
fn validTicket(ticket: []u64, columns: []Column) bool {
    var allValid = true;
    for (ticket) |n| {
        var anyValid = false;
        for (columns) |column| {
            anyValid = validColumn(n, column);
            if (anyValid) break;
        }
        if (!anyValid) {
            allValid = false;
            break;
        }
    }
    return allValid;
}

pub fn part1(allocator: *mem.Allocator, input: Input) !u64 {
    var rate: u64 = 0;
    for (input.tickets) |ticket| {
        for (ticket) |n| {
            var anyValid = false;
            for (input.columns) |column| {
                anyValid = validColumn(n, column);
                if (anyValid) break;
            }
            if (!anyValid) rate += n;
        }
    }
    return rate;
}

test "part1" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator, test_input);
    testing.expectEqual(@intCast(u64, 71), try part1(testing.allocator, input));
    input.free(allocator);
}

pub fn part2(allocator: *mem.Allocator, input: Input) !u64 {
    const num_columns = input.columns.len;

    // filter out valid tickets
    var good_tickets_list = ArrayList([]u64).init(allocator);
    defer good_tickets_list.deinit();

    for (input.tickets) |ticket| {
        if (validTicket(ticket, input.columns))
            try good_tickets_list.append(ticket);
    }

    // keep track of which ticket values can be part of this column
    var options_map = try allocator.alloc([]bool, num_columns);
    defer allocator.free(options_map);

    for (options_map) |*options| {
        options.* = try allocator.alloc(bool, num_columns);
        mem.set(bool, options.*, true);
    }
    defer for (options_map) |c| allocator.free(c);

    // set candidates
    for (options_map) |options, c| {
        for (options) |*valid, t| {
            for (good_tickets_list.items) |ticket| {
                valid.* = validColumn(ticket[t], input.columns[c]);
                if (!valid.*) break;
            }
        }
    }

    var col_to_tix = try allocator.alloc(usize, num_columns);
    defer allocator.free(col_to_tix);
    mem.set(usize, col_to_tix, num_columns);

    // eliminate candidates
    var count: usize = 0;
    while (count < num_columns) : (count += 1) {
        var idx: usize = undefined;

        // find a column with a single candidate
        for (options_map) |options, c| {
            const candidate = &[1]bool{true};
            const candidates = countOccurences(bool, options, candidate);
            if (candidates == 1) {
                // find the candidate
                idx = mem.indexOf(bool, options, candidate).?;

                // save candidate
                col_to_tix[c] = idx;
                break;
            }
        } else unreachable;

        // remove candidate from all options
        for (options_map) |options, c| {
            options[idx] = false;
        }
    }

    var total: u64 = 1;
    for (input.columns) |column, c| {
        if (mem.startsWith(u8, column.name, "departure"))
            total *= input.my_ticket[col_to_tix[c]];
    }

    return total;
}

test "part2" {
    const allocator = testing.allocator;
    var input = try cleanInput(allocator,
        \\class: 0-1 or 4-19
        \\departure row: 0-5 or 8-19
        \\departure seat: 0-13 or 16-19
        \\
        \\your ticket:
        \\11,12,13
        \\
        \\nearby tickets:
        \\3,9,18
        \\15,1,5
        \\5,14,9
    );
    testing.expectEqual(@intCast(u64, 11 * 13), try part2(allocator, input));
    input.free(allocator);
}

pub fn main() !void {
    const file = try common.readFile(alloc, "inputs/day16.txt");
    defer alloc.free(file);
    const input = try cleanInput(alloc, file);
    defer input.free(alloc);

    warn("part1: {}\n", .{try part1(alloc, input)});
    warn("part2: {}\n", .{try part2(alloc, input)});
}
