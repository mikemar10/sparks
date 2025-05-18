package main
import "core:fmt"
import "core:math/rand"
import "core:time"
import rl "vendor:raylib"

StartState :: struct {}
WaitState :: struct {
	duration: time.Duration,
	stopwatch: time.Stopwatch,
}
FoulState :: struct {}
ClickState :: struct {
	stopwatch: time.Stopwatch,
}
ResultsState :: struct {}

State :: struct {
	color: rl.Color,
	msg: cstring,
	variant: union #no_nil {
		StartState,
		WaitState,
		FoulState,
		ClickState,
		ResultsState,
	},
}

Db :: struct {
	state: State,
}

set_state :: proc(db: ^Db, s: State) {
	db.state = s
}

render_state :: proc(s: State) {
	rl.ClearBackground(s.color)
	rl.DrawText(s.msg, 0, 0, 32, rl.WHITE)
}

start_state :: proc {
	start_state_from_foul,
	start_state_from_results,
}

start_state_from_foul :: proc(from: FoulState, color := rl.BLUE, msg: cstring = "Click to start") -> State {
	return State { color, msg, StartState {} }
}

start_state_from_results :: proc(from: ResultsState, color := rl.BLUE, msg: cstring = "Click to start") -> State {
	return State { color, msg, StartState {} }
}

wait_state :: proc(from: StartState, color := rl.BLUE, msg: cstring = "Wait...") -> State {
	variant := WaitState {
		duration = time.Duration(DELAY_MIN + (rand.uint64() % DELAY_MAX)) * time.Millisecond,
	}
	time.stopwatch_start(&variant.stopwatch)

	return State { color, msg, variant }
}

foul_state :: proc(from: WaitState, color := rl.RED, msg: cstring = "You clicked too soon!") -> State {
	return State { color, msg, FoulState {} }
}

click_state :: proc(from: WaitState, color := rl.GREEN, msg: cstring = "CLICK NOW!") -> State {
	variant := ClickState {}
	time.stopwatch_start(&variant.stopwatch)
	return State { color, msg, variant }
}

results_state :: proc(from: ClickState, duration: time.Duration, color := rl.BLUE, msg := "Reflex time: %v") -> State {
	return State {
		color,
		fmt.ctprintf(msg, duration),
		ResultsState {},
	}
}