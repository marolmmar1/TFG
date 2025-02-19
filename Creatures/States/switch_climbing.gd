extends State

@export var max_threshold: int = 50 #Tile size + some tolerance #HACK
@export var min_threshold: int = 25 #Tile size - some tolerance
@export var stop_time_1: float = 0.15
@export var move_time: float = 0.7
@export var stop_time_2: float = 0.15

@onready var idle_state = $"../Idle"
@onready var idle_wall_state = $"../IdleWall"

var anim_time := 0.0
var target_node
var final_state
var speed

func enter(vars):
	target_node = vars["target node"] as Vector2

	if target_node.y < controller.position.y: #Why y in godot 2d is down? aaaaaaaaaa
		final_state = idle_state
	else:
		final_state = idle_wall_state

	var dist = abs(controller.position.x - target_node.x) + abs(controller.position.y - target_node.y)
	speed = dist / move_time


	locked = true
	anim_time = 0.0


func check_conditions(vars) -> bool:
	if not (controller.is_on_wall() or controller.is_on_floor()):
		return false
	
	var _target_node = vars["target node"] as Vector2
	if _target_node and abs(controller.position.x - _target_node.x) > min_threshold and abs(controller.position.y - _target_node.y) > min_threshold \
		and controller.position.distance_to(_target_node) < sqrt(max_threshold * max_threshold + max_threshold * max_threshold):
		return true
	
	return false


func tick(delta):

	anim_time += delta

	if anim_time < stop_time_1:
		# Stay still first
		controller.velocity = Vector2.ZERO

	elif anim_time < stop_time_1 + move_time:
		# Move towards target node

		var t = (anim_time - stop_time_1) / move_time
		var v = 4 * t * (1 - t) * speed * sqrt(2) #I'm no mathematician and don't know how this works. But I've made it straight up from instict and it works lmao

		controller.velocity.x = v if (target_node.x - controller.position.x) > 0 else -v
		controller.velocity.y = v if (target_node.y - controller.position.y) > 0 else -v

	elif anim_time < stop_time_1 + move_time + stop_time_2:
		# Stay still finally
		controller.velocity = Vector2.ZERO
	else:
		# Animation complete		
		
		if final_state == idle_wall_state and not controller.is_on_wall():
			controller.velocity.x = 10 if (target_node.x - controller.position.x) > 0 else -10 #HACK hardcoded
		elif final_state == idle_state and not controller.is_on_floor():
			controller.velocity.y = 10

		else:
			locked = false
			on_change_state.emit(final_state, {})

	controller.move_and_slide()
