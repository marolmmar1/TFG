extends State

@export var speed: float = 65.0
@export var fix_speed: float = 5.0

@onready var fall_state = $"../Fall"

var wall_dir
var target_node

func enter(vars):
	target_node = vars["target node"]

	assert(controller.check_is_on_wall())
	wall_dir = controller.get_wall_dir()


func check_conditions(vars) -> bool:
	return controller.check_is_on_wall()

func tick(delta):
	
	controller.velocity.y = (target_node - controller.position).normalized().y * speed
	controller.velocity.x = (target_node - controller.position).normalized().x * fix_speed

	controller.move_and_slide()

	if not controller.check_is_on_wall():
		on_change_state.emit(fall_state, {})
