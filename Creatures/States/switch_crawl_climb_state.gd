extends State

@export var speed: float = 65.0

@onready var fall_state = $"../Fall"

var target_node
var movement_normal

func enter(vars):
	target_node = vars["target node"] as Vector2

	movement_normal = Vector2i(round((target_node - controller.position).normalized().x), round(-(target_node - controller.position).normalized().y))

	controller.set_collision_for_tunnel(false)

func exit():
	controller.set_collision_for_tunnel(true)


func check_conditions(vars) -> bool:
	if not (controller.check_is_on_wall() or controller.check_is_on_tunnel()):
		return false
		
	return true


func tick(delta):

	if not (controller.check_corner(movement_normal) or controller.check_is_on_tunnel() or controller.check_is_on_wall()):
		on_change_state.emit(fall_state, {})

	controller.velocity = (target_node - controller.position).normalized() * speed

	controller.move_and_slide()
