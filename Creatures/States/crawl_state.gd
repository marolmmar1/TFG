extends State

@export var speed: float = 100.0
@export var raycast_length: float = 10.0


func enter(vars):
	controller.velocity = vars["direction"] * speed
	
func check_conditions(vars) -> bool:
	return (controller.test_move(controller.global_transform, Vector2.UP * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2.DOWN * raycast_length)) or \
		(controller.test_move(controller.global_transform, Vector2.RIGHT * raycast_length) and \
		controller.test_move(controller.global_transform, Vector2.LEFT * raycast_length))

func tick(delta):

	controller.move_and_slide()
