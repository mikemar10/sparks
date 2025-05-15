//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");
const rl = @import("raylib");

const State = enum {
    start,
    wait,
    foul,
    click,
    results,
};

const DB = struct {
    state: State = State.start,
    delay_duration: u64 = 0,
    reflex_duration: u64 = 0,
    timer_start: std.time.Instant,

    const Self = @This();
    pub fn reset(self: Self) void {
        self = Self{
            .state = State.start,
            .delay_duration = 0,
            // TODO: better represent milliseconds with these constants below
            .reflex_duration = std.crypto.Random.intRangeAtMost(u64, 500_000_000, 2_000_000_000),
            .timer_start = std.time.Instant.now(),
        };
    }
};

const start_color = rl.Color.blue;
const wait_color = rl.Color.blue;
const foul_color = rl.Color.red;
const click_color = rl.Color.green;
const results_color = rl.Color.blue;

const start_msg = "Click to start";
const wait_msg = "Wait...";
const foul_msg = "You clicked too soon!";
const click_msg = "CLICK NOW!";
const results_msg = "Reaction time: {s}ms";

pub fn main() !void {
    var db = DB{};
    db.reset();
    const screenWidth = 1280;
    const screenHeight = 800;
    rl.initWindow(screenWidth, screenHeight, "reflex test");
    defer rl.closeWindow();

    //rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        switch (db.state) {
            .start => {},
            .wait => {},
            .foul => {},
            .click => {},
            .results => {},
        }

        rl.clearBackground(rl.Color.black);
        rl.drawText("Congrats! You finally got around to doing this", 190, 200, 20, rl.Color.light_gray);
    }
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!
}
