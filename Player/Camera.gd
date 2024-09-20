extends Camera3D

@export_category("Provided")

@export var player: Node3D

@export var locked_on_target: Node3D

@export var camera_target: Node3D


@export_category("Main")

@export var speed : float = 5.0

@export var max_camera_offset : float = 1.35


@export_category("DEBUG")

var debug_draw = null

@export var switch_target_debug : bool = false : set = switch_target_debug_func #DEBUG

func switch_target_debug_func(a: bool) -> void: #DEBUG
	switch_target()

@export var switch_lock_on_debug : bool = false : set = switch_lock_on_debug_func #DEBUG

func switch_lock_on_debug_func(a: bool) -> void: #DEBUG
	switch_lock_on()

@export var possible_targets: Array[Node]

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

func add_target(target: Node3D) -> void:
	if target not in possible_targets:
		possible_targets.append(target)

func _ready():
	possible_targets = get_tree().get_nodes_in_group("Targetables")
	EventSystem.main_game_bus.on_enemy_enter.connect(add_target)

func _process(delta):

	if camera_target:
		if locked_on_target:
			var camera_offset = locked_on_target.global_position * Vector3(1, 0, 1) - camera_target.global_position
			camera_offset = camera_offset.normalized() * clamp(camera_offset.length(), 0, max_camera_offset)
			position = lerp(position, camera_target.global_position + camera_offset * Vector3(1, 0, 1), delta * speed)
		else:
			position = lerp(position, camera_target.global_position, delta * speed)

	#DEBUG
	%Draw3D.clear()
	if player:
		%Draw3D.draw_line([player.global_position, self.global_position - Vector3(0, 0.1, 0)], Color.GREEN)
	if locked_on_target:
		%Draw3D.draw_line([locked_on_target.global_position, self.global_position - Vector3(0, 0.1, 0)], Color.RED)
	for target in possible_targets:
		if target and target != locked_on_target:
			%Draw3D.draw_line([target.global_position, self.global_position - Vector3(0, 0.1, 0)], Color.YELLOW)
