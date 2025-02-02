const std = @import("std");
const builtin = @import("builtin");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "bool literals" {
    try expect(true);
    try expect(!false);
}

test "cast bool to int" {
    if (builtin.zig_backend == .stage2_spirv64) return error.SkipZigTest;

    const t = true;
    const f = false;
    try expectEqual(@as(u32, 1), @boolToInt(t));
    try expectEqual(@as(u32, 0), @boolToInt(f));
    try expectEqual(-1, @bitCast(i1, @boolToInt(t)));
    try expectEqual(0, @bitCast(i1, @boolToInt(f)));
    try expectEqual(u1, @TypeOf(@boolToInt(t)));
    try expectEqual(u1, @TypeOf(@boolToInt(f)));
    try nonConstCastBoolToInt(t, f);
}

fn nonConstCastBoolToInt(t: bool, f: bool) !void {
    try expectEqual(@as(u32, 1), @boolToInt(t));
    try expectEqual(@as(u32, 0), @boolToInt(f));
    try expectEqual(@as(i1, -1), @bitCast(i1, @boolToInt(t)));
    try expectEqual(@as(i1, 0), @bitCast(i1, @boolToInt(f)));
    try expectEqual(u1, @TypeOf(@boolToInt(t)));
    try expectEqual(u1, @TypeOf(@boolToInt(f)));
}

test "bool cmp" {
    try expect(testBoolCmp(true, false) == false);
}
fn testBoolCmp(a: bool, b: bool) bool {
    return a == b;
}

const global_f = false;
const global_t = true;
const not_global_f = !global_f;
const not_global_t = !global_t;
test "compile time bool not" {
    try expect(not_global_f);
    try expect(!not_global_t);
}

test "short circuit" {
    try testShortCircuit(false, true);
    comptime try testShortCircuit(false, true);
}

fn testShortCircuit(f: bool, t: bool) !void {
    var hit_1 = f;
    var hit_2 = f;
    var hit_3 = f;
    var hit_4 = f;

    if (t or x: {
        try expect(f);
        break :x f;
    }) {
        hit_1 = t;
    }
    if (f or x: {
        hit_2 = t;
        break :x f;
    }) {
        try expect(f);
    }

    if (t and x: {
        hit_3 = t;
        break :x f;
    }) {
        try expect(f);
    }
    if (f and x: {
        try expect(f);
        break :x f;
    }) {
        try expect(f);
    } else {
        hit_4 = t;
    }
    try expect(hit_1);
    try expect(hit_2);
    try expect(hit_3);
    try expect(hit_4);
}
