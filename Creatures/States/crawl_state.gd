extends State

@export var speed: float = 100.0
@export var raycast_length: float = 10.0
@export var stamina_cost_per_second: float = 0.4

var target_node

func enter(vars):
	target_node = vars["target node"]

	controller.set_collision_for_tunnel(false) # Just in case
	
func check_conditions(vars) -> bool:
	return (controller.test_move(controller.global_transform, Vector2.UP * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2.DOWN * raycast_length)) or \
		(controller.test_move(controller.global_transform, Vector2.RIGHT * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2.LEFT * raycast_length)) or \
		(controller.test_move(controller.global_transform, Vector2(1, 1) * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2(-1, -1) * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2(1, -1) * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2(-1, 1) * raycast_length))

func tick(delta):

	controller.velocity = (target_node - controller.position).normalized() * speed

	controller.move_and_slide()
	controller.data.stamina -= delta * stamina_cost_per_second
