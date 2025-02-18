extends State

@export var speed: float = 65.0

@onready var fall_state = $"../Fall"

var wall_dir

func enter(vars):
	controller.velocity.y = vars["direction"].y * speed

	assert(controller.is_on_wall())
	wall_dir = -controller.get_slide_collision(0).get_normal()

	controller.velocity.x = wall_dir.x * 0.1


func check_conditions(vars) -> bool:
	return controller.is_on_wall()

func tick(delta):

	if not controller.is_on_wall():
		on_change_state.emit(fall_state, {})

	controller.move_and_slide()
