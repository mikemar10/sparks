const std = @import("std");
const rl = @import("raylib");
const cfg = @import("config.zig");
const DB = @import("db.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const allocator = arena.allocator();
    defer arena.deinit();

    var db = try DB.init(&allocator);
    db.reset();

    rl.initWindow(cfg.screen_width, cfg.screen_height, cfg.screen_title);
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        // render the background color
        const bg_color = switch (db.state) {
            .start => cfg.start_color,
            .wait => cfg.wait_color,
            .foul => cfg.foul_color,
            .click => cfg.click_color,
            .results => cfg.results_color,
        };
        rl.clearBackground(bg_color);

        // render the message and FPS
        const msg = switch (db.state) {
            .start => cfg.start_msg,
            .wait => cfg.wait_msg,
            .foul => cfg.foul_msg,
            .click => cfg.click_msg,
            .results => try std.fmt.bufPrintZ(db.msg_buffer, cfg.results_msg, .{db.reflex_duration / std.time.ns_per_ms}),
        };
        rl.drawText(msg, 0, 0, 32, cfg.text_color);
        rl.drawFPS(0, 32);

        // handle state transitions on mouse click
        if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
            switch (db.state) {
                .start => {
                    db.reset();
                    db.state = .wait;
                },
                .wait => {
                    db.state = .foul;
                },
                .foul => {
                    db.state = .start;
                },
                .click => {
                    db.reflex_duration = db.timer.read();
                    db.state = .results;
                },
                .results => {
                    db.state = .start;
                },
            }
        }

        // check wait timer if in wait state
        if (db.state == .wait) {
            if (db.timer.read() >= db.wait_duration) {
                db.timer.reset();
                db.state = .click;
            }
        }
    }
}
