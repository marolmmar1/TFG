extends State

@export var gravity: float = 800

@onready var idle_state = $"../Idle"

func check_conditions(vars) -> bool:
	return not controller.check_is_on_floor()

func tick(delta):

	if controller.check_is_on_floor():
		on_change_state.emit(idle_state, {})

	controller.velocity.y += gravity * delta
	controller.move_and_slide()
