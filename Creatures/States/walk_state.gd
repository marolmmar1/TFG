extends State

@export var speed: float = 100.0
@export var fix_speed: float = 5.0

@onready var fall_state = $"../Fall"

var target_node

func enter(vars):
	target_node = vars["target node"]

func check_conditions(vars) -> bool:
	return controller.check_is_on_floor()

func tick(delta):

	controller.velocity.x = (target_node - controller.position).normalized().x * speed
	controller.velocity.y = (target_node - controller.position).normalized().y * fix_speed



	if not controller.check_is_on_floor():
		on_change_state.emit(fall_state, {})
