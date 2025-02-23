extends State

@export var speed: float = 65.0

@onready var fall_state = $"../Fall"

var target_node
var movement_normal

func enter(vars):
	target_node = vars["target node"] as Vector2

	movement_normal = Vector2i(round((target_node - controller.position).normalized().x), round(-(target_node - controller.position).normalized().y))

func check_conditions(vars) -> bool:
	var _target_node = vars["target node"] as Vector2

	# Differentiate between going to climb and going to walk
	if _target_node.y < controller.position.y:
		return controller.check_is_on_wall()
	else:
		return controller.check_is_on_floor()
	

func tick(delta):

	if not controller.check_corner(movement_normal):
		on_change_state.emit(fall_state, {})

	controller.velocity = (target_node - controller.position).normalized() * speed

	controller.move_and_slide()
