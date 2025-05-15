const std = @import("std");
const rl = @import("raylib");

pub const screen_width = 1280;
pub const screen_height = 800;
pub const screen_title = "reflex test";

pub const delay_min = 500 * std.time.ns_per_ms;
pub const delay_max = 2000 * std.time.ns_per_ms;

pub const text_color = rl.Color.white;

pub const start_color = rl.Color.blue;
pub const wait_color = rl.Color.blue;
pub const foul_color = rl.Color.red;
pub const click_color = rl.Color.green;
pub const results_color = rl.Color.blue;

pub const start_msg = "Click to start";
pub const wait_msg = "Wait...";
pub const foul_msg = "You clicked too soon!";
pub const click_msg = "CLICK NOW!";
pub const results_msg = "Reflex time: {d}ms";
