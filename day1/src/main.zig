const std = @import("std");

const LocationIds = struct {
    firstList: std.ArrayList(i32),
    secondList: std.ArrayList(i32),

    pub fn init(allocator: std.mem.Allocator) !LocationIds {
        return LocationIds{
            .firstList = std.ArrayList(i32).init(allocator),
            .secondList = std.ArrayList(i32).init(allocator),
        };
    }

    pub fn deinit(self: *LocationIds) void {
        self.firstList.deinit();
        self.secondList.deinit();
    }

    pub fn add(self: *LocationIds, first: i32, second: i32) !void {
        try self.firstList.append(first);
        try self.secondList.append(second);
    }

    pub fn sortAll(self: *LocationIds) void {
        std.sort.heap(i32, self.firstList.items, void{}, std.sort.asc(i32));
        std.sort.heap(i32, self.secondList.items, void{}, std.sort.asc(i32));
    }

    pub fn difference(self: *const LocationIds) i32 {
        var result: i32 = 0;
        const first = self.firstList.items;
        const second = self.secondList.items;
        for (first, second) |firstItem, secondItem| {
            if (firstItem > secondItem) {
                result = result + firstItem - secondItem;
            } else {
                result = result + secondItem - firstItem;
            }
        }
        return result;
    }
};

pub fn main() !void {
    var stdin = std.io.getStdIn();
    var reader = stdin.reader();
    var locationIds = try LocationIds.init(std.heap.page_allocator);
    defer locationIds.deinit();

    var buffer: [4096]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const numbers = try parseInputLine(line);
        try locationIds.add(numbers[0], numbers[1]);
    }
    locationIds.sortAll();
    const result = locationIds.difference();

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Result: {}\n", .{result});
}

fn parseInputLine(line: []const u8) ![2]i32 {
    var numbers = std.mem.splitSequence(u8, line, "   ");
    const one = try std.fmt.parseInt(i32, numbers.first(), 10);
    const two = try std.fmt.parseInt(i32, numbers.next().?, 10);
    return .{ one, two };
}
