package main
import "core:fmt"

Example :: struct {
	name: string,
	print_name: proc(Example),
}

main :: proc() {
	example := Example {
		name = "Example",
		print_name = proc(self: Example) {
			fmt.printfln("My name is %v", self.name)
		},
	}

	// This usage of the Selector Call Expression Operator:
	example->print_name()
	// Is equivalent to:
	example.print_name(example)
}