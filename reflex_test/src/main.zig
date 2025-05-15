const std = @import("std");
const rl = @import("raylib");

// TODO: better seed
var default_prng = std.Random.DefaultPrng.init(123456);
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
            .delay_duration = prng.intRangeAtMost(u64, 500 * std.time.ns_per_ms, 2000 * std.time.ns_per_ms),
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
const results_msg = "Reaction time: {d}ms";

const screenWidth = 1280;
const screenHeight = 800;

pub fn main() !void {
    var db = try DB.reset();
    rl.initWindow(screenWidth, screenHeight, "reflex test");
    defer rl.closeWindow();

    //rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawFPS(0, 32);

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
                    db.timer_start = now;
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
                var buffer: [256]u8 = undefined;
                const results_msg_formatted = try std.fmt.bufPrintZ(&buffer, results_msg, .{db.reflex_duration / std.time.ns_per_ms});
                rl.drawText(results_msg_formatted, 0, 0, 32, text_color);

                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    db.state = State.start;
                }
            },
        }
    }
}
