extends Node

@export var max_count: int = 15

var counter: int = 0

#HACK Probably should use signals but it's not worth the complexity

func add_loop(amount: int):

	counter += amount
	if counter > max_count:
		counter = max_count

func can_process_loop() -> bool:
	return counter < max_count

func _process(delta: float) -> void:
	counter = 0