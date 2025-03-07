extends CharacterBody2D

@export_category("Main")
@export var ai_time = 0.1
@export var raycasts_length = 25

@onready var astar_graph: Node2D = $"../AStarGraph"
@onready var low_level_state_manager: Node2D = $"../LowLevelStateManager"

@onready var controller = $Controller
@onready var data = $CreatureData
@onready var ai = $AI
@onready var ai_timer: Timer = $AITimer

@onready var down_raycast: RayCast2D = $Raycasts/DownRaycast
@onready var up_raycast: RayCast2D = $Raycasts/UpRaycast
@onready var left_raycast: RayCast2D = $Raycasts/LeftRaycast
@onready var right_raycast: RayCast2D = $Raycasts/RightRaycast
@onready var dl_raycast: RayCast2D = $Raycasts/DLRaycast
@onready var dr_raycast: RayCast2D = $Raycasts/DRRaycast
@onready var ul_raycast: RayCast2D = $Raycasts/ULRaycast
@onready var ur_raycast: RayCast2D = $Raycasts/URRaycast

#DEBUG
var target:
	set(value):
		target = value
		ai.target = value

func _ready() -> void:
	assert(astar_graph)
	assert(low_level_state_manager)

	controller.init(self)
	ai.init(astar_graph, controller, low_level_state_manager, self)

	down_raycast.target_position = Vector2(0, raycasts_length)
	up_raycast.target_position = Vector2(0, -raycasts_length)
	left_raycast.target_position = Vector2(-raycasts_length, 0)
	right_raycast.target_position = Vector2(raycasts_length, 0)
	dl_raycast.target_position = Vector2(-raycasts_length, raycasts_length)
	dr_raycast.target_position = Vector2(raycasts_length, raycasts_length)
	ul_raycast.target_position = Vector2(-raycasts_length, -raycasts_length)
	ur_raycast.target_position = Vector2(raycasts_length, -raycasts_length)

	ai_timer.wait_time = ai_time
	ai_timer.timeout.connect(ai_tick)
	ai_timer.start()

func check_is_on_floor() -> bool:
	return down_raycast.is_colliding()

func check_is_on_wall() -> bool:
	return left_raycast.is_colliding() or right_raycast.is_colliding()

func check_is_on_tunnel() -> bool:
	if down_raycast.is_colliding() and up_raycast.is_colliding():
		return true
	elif left_raycast.is_colliding() and right_raycast.is_colliding():
		return true
	elif dl_raycast.is_colliding() and dr_raycast.is_colliding() and ul_raycast.is_colliding() and ur_raycast.is_colliding():
		return true

	return false

func check_corner(corner: Vector2i) -> bool:
	if corner == Vector2i(1, 1):
		return dr_raycast.is_colliding()
	elif corner == Vector2i(-1, 1):
		return dl_raycast.is_colliding()
	elif corner == Vector2i(1, -1):
		return ur_raycast.is_colliding()
	elif corner == Vector2i(-1, -1):
		return ul_raycast.is_colliding()
	else:
		return false
	

func get_wall_dir() -> Vector2: #TODO do something if both
	if left_raycast.is_colliding():
		return Vector2.LEFT
	elif right_raycast.is_colliding():
		return Vector2.RIGHT

	return Vector2.ZERO

func set_collision_for_tunnel(value: bool): # Disable or enable collision with tunnel gates while in or out of tunnel
	set_collision_layer_value(2, value)
	set_collision_mask_value(2, value)

	down_raycast.set_collision_mask_value(2, value)
	up_raycast.set_collision_mask_value(2, value)
	left_raycast.set_collision_mask_value(2, value)
	right_raycast.set_collision_mask_value(2, value)
	dl_raycast.set_collision_mask_value(2, value)
	dr_raycast.set_collision_mask_value(2, value)
	ul_raycast.set_collision_mask_value(2, value)
	ur_raycast.set_collision_mask_value(2, value)


func ai_tick():
	await ai.tick() #DEBUG
	ai_timer.start()
