extends State

@export var gravity: float = 800
@export var drag_force: float = 1250
@export var velocity_end_threshold: float = 10

@onready var idle_state = $"../Idle"
@onready var idle_climb_state = $"../IdleClimb"
@onready var idle_crawl_state = $"../IdleCrawl"
@onready var stunned_state = $"../Stunned"

var should_grab = true

func enter(vars):
	if vars.has("should grab"):
		should_grab = vars["should grab"]

	locked = true

func check_conditions(vars) -> bool:
	return not controller.check_is_on_floor()

func tick(delta):

	if controller.check_is_on_floor() or controller.check_is_on_wall() or controller.check_is_on_tunnel():

		if should_grab:
			controller.velocity -= (controller.velocity.normalized() * drag_force * delta).limit_length(controller.velocity.length())
			
		if controller.velocity.length() < velocity_end_threshold:
			end_state()
	
	controller.velocity.y += gravity * delta
	controller.move_and_slide()

func end_state():
	locked = false

	if controller.check_is_on_floor():
		on_change_state.emit(idle_state, {})
	elif controller.check_is_on_wall():
		on_change_state.emit(idle_climb_state, {})
	elif controller.check_is_on_tunnel():
		on_change_state.emit(idle_crawl_state, {})
	
func exit():
	locked = false