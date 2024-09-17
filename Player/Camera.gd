@tool
extends Camera3D

@export_category("Provided")

@export var player: Node3D

@export var locked_on_target: Node3D

@export var possible_targets: Array[Node3D]

@export var camera_target: Node3D


@export_category("Main")

@export var speed : float = 5.0

@export var max_camera_offset : float = 1.35


@export_category("DEBUG")

@export var switch_target_debug : bool = false : set = switch_target_debug_func #DEBUG

func switch_target_debug_func(a: bool) -> void: #DEBUG
	switch_target()

@export var switch_lock_on_debug : bool = false : set = switch_lock_on_debug_func #DEBUG

func switch_lock_on_debug_func(a: bool) -> void: #DEBUG
	switch_lock_on()


func switch_lock_on():
	if locked_on_target:
		locked_on_target = null
	else:
		locked_on_target = possible_targets[0]

func switch_target() -> void:
	#TODO we could do this based on direction but for now I'll just make it loop to simplify
	for i in range(possible_targets.size()):
		if possible_targets[i] == locked_on_target:
			i += 1
			i = i % possible_targets.size()
			locked_on_target = possible_targets[i]
			break


func _process(delta):

	if camera_target:
		if locked_on_target:
			var camera_offset = locked_on_target.global_position * Vector3(1, 0, 1) - camera_target.global_position
			camera_offset = camera_offset.normalized() * clamp(camera_offset.length(), 0, max_camera_offset)
			position = lerp(position, camera_target.global_position + camera_offset * Vector3(1, 0, 1), delta * speed)
		else:
			position = lerp(position, camera_target.global_position, delta * speed)

	#DEBUG
	if player:
		DebugDraw3D.draw_line(player.position, self.position, Color.GREEN)
	if locked_on_target:
		DebugDraw3D.draw_line(locked_on_target.position, self.position, Color.RED)
	for target in possible_targets:
		if target and target != locked_on_target:
			DebugDraw3D.draw_line(target.position, self.position, Color.YELLOW)
