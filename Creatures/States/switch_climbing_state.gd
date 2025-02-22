extends State

@export var max_threshold: int = 50 #Tile size + some tolerance #HACK
@export var min_threshold: int = 25 #Tile size - some tolerance
@export var anim_duration: float = 1.0 #TODO get this from the sprite animator
@export var fix_pos_speed: float = 100

@onready var idle_state = $"../Idle"
@onready var idle_climb_state = $"../IdleClimb"

var anim_time := 0.0
var target_node
var source_node
var final_state
var completed := false

func enter(vars):
	target_node = vars["target node"] as Vector2
	source_node = vars["source node"] as Vector2

	if target_node.y < controller.position.y: #Why y in godot 2d is down? aaaaaaaaaa
		final_state = idle_state
	else:
		final_state = idle_climb_state


	locked = true
	completed = false
	anim_time = 0.0


func check_conditions(vars) -> bool:
	if not (controller.check_is_on_wall() or controller.check_is_on_floor()):
		return false
	
	var _target_node = vars["target node"] as Vector2
	if _target_node and abs(controller.position.x - _target_node.x) > min_threshold and abs(controller.position.y - _target_node.y) > min_threshold \
		and controller.position.distance_to(_target_node) < sqrt(max_threshold * max_threshold + max_threshold * max_threshold):
		return true
	
	return false


func tick(delta):

	if not completed:
		anim_time += delta

		if anim_time < 0.1: # Time to get into position
			# Sprite anim
			if controller.check_is_on_wall():
				controller.velocity = Vector2(0, source_node.y - controller.position.y).normalized() * fix_pos_speed
			else:
				controller.velocity = Vector2(source_node.x - controller.position.x, 0).normalized() * fix_pos_speed
			
			controller.move_and_slide()

		elif anim_time < anim_duration + 0.1:
			# Move towards target node
			# Sprite anim
			controller.velocity = Vector2.ZERO

		else:
			# Animation complete
		
			controller.position = target_node
			completed = true

	else:
		#Fix position

		if final_state == idle_climb_state and not controller.check_is_on_wall():
			controller.velocity.x = fix_pos_speed if (target_node.x - source_node.x) < 0 else -fix_pos_speed
			controller.move_and_slide()
		elif final_state == idle_state and not controller.check_is_on_floor():
			controller.velocity.y = fix_pos_speed
			controller.move_and_slide()

		else:
			# Release state
			locked = false
			on_change_state.emit(final_state, {})

