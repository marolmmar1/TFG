extends State

@export var gravity: float = 750

@onready var idle_state = $"../Idle"

func check_conditions(vars) -> bool:
	return not controller.is_on_floor()

func tick(delta):

	if controller.is_on_floor():
		on_change_state.emit(idle_state, {})

	controller.velocity.y += gravity * delta
	controller.move_and_slide()
