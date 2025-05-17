package main
import "core:fmt"
import "core:mem"
import "core:time"
import rl "vendor:raylib"

main :: proc() {
	// Uses the tracking allocator in debug mode to find out where we're leaking memory
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	db := Db{}
	reset(&db)

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_TITLE)
	for !rl.WindowShouldClose() {
		render(&db)
		update(&db)
	}

	rl.CloseWindow()
}

render :: proc(db: ^Db) {
	rl.BeginDrawing()
	rl.DrawFPS(0, 32)
	switch db.state {
	case .Start:
		rl.ClearBackground(START_COLOR)
		rl.DrawText(START_MSG, 0, 0, 32, TEXT_COLOR)
	case .Wait:
		rl.ClearBackground(WAIT_COLOR)
		rl.DrawText(WAIT_MSG, 0, 0, 32, TEXT_COLOR)
	case .Foul:
		rl.ClearBackground(FOUL_COLOR)
		rl.DrawText(FOUL_MSG, 0, 0, 32, TEXT_COLOR)
	case .Click:
		rl.ClearBackground(CLICK_COLOR)
		rl.DrawText(CLICK_MSG, 0, 0, 32, TEXT_COLOR)
	case .Results:
		rl.ClearBackground(RESULTS_COLOR)
		rl.DrawText(db.results_msg, 0, 0, 32, TEXT_COLOR)
	}
	rl.EndDrawing()
}

update :: proc(db: ^Db) {
	switch db.state {
	case .Start:
		if rl.IsMouseButtonPressed(.LEFT) {
			reset(db)
			time.stopwatch_start(&db.stopwatch)
			db.state = .Wait
		}
	case .Wait:
		if rl.IsMouseButtonPressed(.LEFT) {
			db.state = .Foul
		}
		if time.stopwatch_duration(db.stopwatch) >= db.wait_duration {
			time.stopwatch_reset(&db.stopwatch)
			time.stopwatch_start(&db.stopwatch)
			db.state = .Click
		}
	case .Foul:
		if rl.IsMouseButtonPressed(.LEFT) {
			db.state = .Start
		}
	case .Click:
		if rl.IsMouseButtonPressed(.LEFT) {
			db.reflex_duration = time.stopwatch_duration(db.stopwatch)
			db.results_msg = fmt.ctprintf(RESULTS_MSG, db.reflex_duration)
			db.state = .Results
		}
	case .Results:
		if rl.IsMouseButtonPressed(.LEFT) {
			db.state = .Start
		}
	}
}