package main
import rl "vendor:raylib"

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 800
SCREEN_TITLE :: "reflex tester"

TEXT_COLOR :: rl.WHITE
START_COLOR :: rl.BLUE
WAIT_COLOR :: rl.BLUE
FOUL_COLOR :: rl.RED
CLICK_COLOR :: rl.GREEN
RESULTS_COLOR :: rl.BLUE

START_MSG :: "Click to start"
WAIT_MSG :: "Wait..."
FOUL_MSG :: "You clicked too soon!"
CLICK_MSG :: "CLICK NOW!"
RESULTS_MSG :: "Reflex time: %v"

DELAY_MIN :: 500
DELAY_MAX :: 2000