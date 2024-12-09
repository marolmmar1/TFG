extends Node

var locked_on_target: Node3D
@onready var player: Node3D = self.get_parent()

@export_category("Main")
@export var max_enemy_distance : float = 10.0

@export_category("DEBUG")

var debug_draw = null

@export var switch_target_debug : bool = false : set = switch_target_debug_func #DEBUG

func switch_target_debug_func(a: bool) -> void: #DEBUG
	switch_target(Vector3(0,0,0))

@export var switch_lock_on_debug : bool = false : set = switch_lock_on_debug_func #DEBUG

func switch_lock_on_debug_func(a: bool) -> void: #DEBUG
	switch_lock_on()

@export var possible_targets: Array[Node]

func switch_lock_on():
	if locked_on_target:
		locked_on_target = null
	else:
		if possible_targets.size() > 0 and possible_targets[0].global_position.distance_to(player.global_position) < max_enemy_distance:
			possible_targets.sort_custom(func(a, b): return a.global_position.distance_to(player.global_position) < b.global_position.distance_to(player.global_position))
			locked_on_target = possible_targets[0]

func switch_target(dir: Vector3) -> void:

	#TODO maybe add a guard time to prevent switching to a target you don't want in the joystick windback
	
	if locked_on_target:
		var dir_proximity_aux = func(_dir, target): 
			var target_dir = target.global_position - player.global_position
			return _dir.dot(target_dir)

		possible_targets.sort_custom(func(a, b): return dir_proximity_aux.call(dir, a) < dir_proximity_aux.call(dir, b))
		locked_on_target = possible_targets[0]


func add_target(target: Node3D) -> void:
	if target not in possible_targets:
		possible_targets.append(target)

func remove_target(target: Node3D) -> void:
	if target in possible_targets:
		possible_targets.erase(target)
	if locked_on_target == target:
		switch_lock_on() #TODO better turn closest enemy to lock on target instead

func _ready():
	possible_targets = get_tree().get_nodes_in_group("Targetables")
	EventSystem.main_game_bus.on_enemy_enter.connect(add_target)
	EventSystem.main_game_bus.on_enemy_exit.connect(remove_target)

	#DEBUG
	debug_draw = Draw3D.new()
	get_tree().root.get_child(0).add_child(debug_draw)

func _unhandled_input(event):
	if event.is_action_pressed("lock_on"):
		switch_lock_on()

	if event.is_action_pressed("target_down") or event.is_action_pressed("target_up") or event.is_action_pressed("target_left") or event.is_action_pressed("target_right"):
		var dir = Input.get_vector("target_right", "target_left", "target_down", "target_up").normalized()
		switch_target(Vector3(dir.x, 0, dir.y))
	

func _process(delta):

	if locked_on_target and locked_on_target.global_position.distance_to(player.global_position) > max_enemy_distance:
		switch_lock_on()

	#DEBUG
	debug_draw.clear()
	if locked_on_target:
		debug_draw.draw_line([locked_on_target.global_position, player.global_position - Vector3(0, 0.1, 0)], Color.RED)
	for target in possible_targets:
		if target and target != locked_on_target:
			debug_draw.draw_line([target.global_position, player.global_position - Vector3(0, 0.1, 0)], Color.YELLOW)

