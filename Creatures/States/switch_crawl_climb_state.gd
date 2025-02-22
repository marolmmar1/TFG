extends State

@export var max_threshold: int = 40 #Tile size + some tolerance #HACK
@export var min_threshold: int = 25 #Tile size - some tolerance
@export var anim_duration: float = 1.0 #TODO get this from the sprite animator
@export var fix_pos_speed: float = 100

@onready var idle_climb_state = $"../IdleClimb"
@onready var idle_crawl_state = $"../IdleCrawl"

var anim_time := 0.0
var target_node
var source_node
var final_state
var in_corner: bool
var completed := false

func enter(vars):
	target_node = vars["target node"] as Vector2
	source_node = vars["source node"] as Vector2

	if abs(target_node.x - source_node.x) > min_threshold and abs(target_node.y - source_node.y) > min_threshold:
		in_corner = true
	else:
		in_corner = false

	if vars["current state"] == "crawl":
		final_state = idle_climb_state
	else:
		final_state = idle_crawl_state

	locked = true
	completed = false
	anim_time = 0.0


func check_conditions(vars) -> bool:
	if not (controller.check_is_on_wall() or controller.check_is_on_floor()):
		return false
	
	var _target_node = vars["target node"] as Vector2
	if _target_node and abs(controller.position.x - _target_node.x) > min_threshold and abs(controller.position.y - _target_node.y) > min_threshold \
		or abs(controller.position.x - _target_node.x) < max_threshold and abs(controller.position.y - _target_node.y) < max_threshold:
		return true
	
	return false


func tick(delta):

	if not completed:
		anim_time += delta

		if anim_time < 0.1: # Time to get into position
			# Sprite anim
			if final_state == idle_crawl_state:
				controller.velocity = Vector2(source_node.x - controller.position.x, 0).normalized() * fix_pos_speed
			else:
				controller.velocity = (source_node - controller.position).normalized() * fix_pos_speed
			
			controller.move_and_slide()

		elif anim_time < anim_duration + 0.1:
			# Move towards target node
			# Sprite anim
			controller.velocity = Vector2.ZERO

		else:
			# Animation complete
			if final_state == idle_crawl_state:
				controller.set_collision_for_tunnel(false)
			else:
				controller.set_collision_for_tunnel(true)

			controller.position = target_node
			completed = true

	else:
		#Fix position

		if final_state == idle_climb_state and not controller.check_is_on_wall():
			controller.velocity.x = fix_pos_speed if (target_node.x - source_node.x) < 0 else -fix_pos_speed
			controller.move_and_slide()

		else:
			# Release state
			locked = false
			on_change_state.emit(final_state, {})

