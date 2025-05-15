const std = @import("std");
const rl = @import("raylib");
const cfg = @import("config.zig");

pub fn main() !void {
    rl.initWindow(cfg.screen_width, cfg.screen_height, cfg.screen_title);
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        rl.drawText("Hello raylib world", 0, 0, 32, rl.Color.light_gray);
    }
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
