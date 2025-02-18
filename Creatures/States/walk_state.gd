extends State

@export var speed: float = 100.0

@onready var fall_state = $"../Fall"

func enter(vars):
	controller.velocity.x = vars["direction"].x * speed
	controller.velocity.y = 0.1

func check_conditions(vars) -> bool:
	return controller.is_on_floor()

func tick(delta):

	if not controller.is_on_floor():
		on_change_state.emit(fall_state, {})

	controller.move_and_slide()
