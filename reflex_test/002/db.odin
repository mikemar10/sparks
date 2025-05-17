package main
import "core:math/rand"
import "core:time"

State :: enum {
	Start,
	Wait,
	Foul,
	Click,
	Results,
}

Db :: struct {
	state: State,
	wait_duration: time.Duration,
	reflex_duration: time.Duration,
	stopwatch: time.Stopwatch,
	results_msg: cstring,
}

reset :: proc(db: ^Db) {
	db^ = {
		wait_duration = time.Duration(DELAY_MIN + (rand.uint64() % DELAY_MAX)) * time.Millisecond,
	}
}