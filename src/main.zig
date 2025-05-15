//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");
const rl = @import("raylib");

// TODO: better seed
var default_prng = std.Random.DefaultPrng.init(69420);
const prng = default_prng.random();

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
    pub fn reset() !Self {
        return Self{
            .state = State.start,
            .delay_duration = prng.intRangeAtMost(u64, 500_000_000, 2_000_000_000),
            // TODO: better represent milliseconds with these constants below
            .reflex_duration = 0,
            .timer_start = try std.time.Instant.now(),
        };
    }
};

const text_color = rl.Color.light_gray;
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
    var db = try DB.reset();
    const screenWidth = 1280;
    const screenHeight = 800;
    rl.initWindow(screenWidth, screenHeight, "reflex test");
    defer rl.closeWindow();

    //rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        switch (db.state) {
            .start => {
                rl.clearBackground(start_color);
                rl.drawText(start_msg, 0, 0, 32, text_color);
                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    db = try DB.reset();
                    db.state = State.wait;
                }
            },
            .wait => {
                rl.clearBackground(wait_color);
                rl.drawText(wait_msg, 0, 0, 32, text_color);
                const now = try std.time.Instant.now();
                const elapsed = now.since(db.timer_start);

                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    db.state = State.foul;
                }

                if (elapsed >= db.delay_duration) {
                    db.state = State.click;
                }
            },
            .foul => {
                rl.clearBackground(foul_color);
                rl.drawText(foul_msg, 0, 0, 32, text_color);

                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    db.state = State.start;
                }
            },
            .click => {
                rl.clearBackground(click_color);
                rl.drawText(click_msg, 0, 0, 32, text_color);
                const now = try std.time.Instant.now();
                const elapsed = now.since(db.timer_start);

                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    db.reflex_duration = elapsed;
                    db.state = State.results;
                }
            },
            .results => {
                rl.clearBackground(results_color);
                rl.drawText(results_msg, 0, 0, 32, text_color);

                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    db.state = State.start;
                }
            },
        }
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
