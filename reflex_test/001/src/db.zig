const std = @import("std");
const cfg = @import("config.zig");

state: State = .start,
wait_duration: u64 = undefined,
reflex_duration: u64 = 0,
timer: std.time.Timer = undefined,
msg_buffer: []u8 = undefined,

var default_prng = std.Random.DefaultPrng.init(123456);
pub const prng: std.Random = default_prng.random();

const Self = @This();

const State = enum {
    start,
    wait,
    foul,
    click,
    results,
};

pub fn init(allocator: *const std.mem.Allocator) !Self {
    default_prng.seed(@intCast(std.time.microTimestamp()));

    return Self{
        .state = .start,
        .wait_duration = prng.intRangeAtMost(u64, cfg.delay_min, cfg.delay_max),
        .reflex_duration = 0,
        .timer = try std.time.Timer.start(),
        .msg_buffer = try allocator.alloc(u8, 256),
    };
}

pub fn reset(self: *Self) void {
    self.state = .start;
    self.wait_duration = prng.intRangeAtMost(u64, cfg.delay_min, cfg.delay_max);
    self.reflex_duration = 0;
    self.timer.reset();
}
