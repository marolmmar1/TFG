extends State

@export var speed: float = 65.0

@onready var fall_state = $"../Fall"

var wall_dir
var target_node

func enter(vars):
	target_node = vars["target node"]

	assert(controller.is_on_wall())
	wall_dir = -controller.get_slide_collision(0).get_normal()


func check_conditions(vars) -> bool:
	return controller.is_on_wall()

func tick(delta):
	controller.velocity.x = wall_dir.x * 0.1
	controller.velocity.y = (target_node - controller.position).normalized().y * speed

	if not controller.is_on_wall():
		on_change_state.emit(fall_state, {})

	controller.move_and_slide()
