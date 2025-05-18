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

	db := Db {}
	set_state(&db, start_state(ResultsState {}))

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
	render_state(db.state)
	rl.EndDrawing()
}

update :: proc(db: ^Db) {
	switch s in db.state.variant {
	case StartState:
		if rl.IsMouseButtonPressed(.LEFT) {
			set_state(db, wait_state(s))
		}
	case WaitState:
		if rl.IsMouseButtonPressed(.LEFT) {
			set_state(db, foul_state(s))
		} else if time.stopwatch_duration(s.stopwatch) >= s.duration {
			set_state(db, click_state(s))
		}
	case FoulState:
		if rl.IsMouseButtonPressed(.LEFT) {
			set_state(db, start_state(s))
		}
	case ClickState:
		if rl.IsMouseButtonPressed(.LEFT) {
			set_state(db, results_state(s, time.stopwatch_duration(s.stopwatch)))
		}
	case ResultsState:
		if rl.IsMouseButtonPressed(.LEFT) {
			set_state(db, start_state(s))
		}
	}
}