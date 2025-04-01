extends Node2D

@export var detect_node_dist: float = 15.0 # Tile size - tolerance
@export var detect_target_dist: float = 30.0 # Depends on creature size. There are probably better ways to do this though
@export var unnecessary_jump_threshold: float = 25.0
@export var bounding_box_margin: float = 20.0

@onready var astar_ai = $AstarAI
@onready var low_level_ai = $LowLevelAI
@onready var high_level_ai = $HighLevelAI
@onready var eat_action_controller = $LowLevelAI/EatAction
@onready var flee_action_controller = $LowLevelAI/FleeAction
@onready var attack_action_controller = $LowLevelAI/AttackAction
@onready var rest_action_controller = $LowLevelAI/RestAction
@onready var leave_action_controller = $LowLevelAI/LeaveAction

var high_level_state_manager:HighLevelStateManager

var astar_graph: Node2D
var low_level_state_manager
var controller
var creature
var calculating_low_action

var path = []
var path_index = 0
var last_dist: float = 100000.0

var target
var current_low_level_action
var current_high_level_action

signal on_target_reached
signal on_current_node_missing(creature)

func _ready():

	high_level_state_manager=get_parent().get_parent().get_parent().get_parent().get_node("HighLevelStateManager")

func init(_astar, _controller, _low_level_state_manager, _creature):
	self.astar_graph = _astar
	self.controller = _controller
	self.low_level_state_manager = _low_level_state_manager
	self.creature = _creature

	controller.on_change_state.connect(check_path_progress)

	astar_ai.astar_graph = astar_graph
	astar_ai.global_astar_manager = get_tree().root.get_node("AstarGlobalManager")
	astar_ai.low_level_state_manager = low_level_state_manager

	astar_ai.walk_speed = controller.find_child("Walk").speed
	astar_ai.climb_speed = controller.find_child("Climb").speed
	astar_ai.crawl_speed = controller.find_child("Crawl").speed
	astar_ai.switch_climbing_speed = controller.find_child("SwitchClimbing").speed
	astar_ai.switch_crawl_walk_speed = controller.find_child("SwitchCrawlWalk").speed
	astar_ai.switch_crawl_climb_speed = controller.find_child("SwitchCrawlClimb").speed

	low_level_ai.init(low_level_state_manager, astar_ai)

	eat_action_controller.on_action_finished.connect(on_action_finished)
	flee_action_controller.on_action_finished.connect(on_action_finished)
	attack_action_controller.on_action_finished.connect(on_action_finished)
	rest_action_controller.on_action_finished.connect(on_action_finished)


#TODO pass to higher AI
func tick():
	# var state = high_level_state_manager.get_state(creature.data)
	# var action = high_level_ai._greedy(state)
	var action = null

	if action:
		if not current_high_level_action or not action.target_door == current_high_level_action.target_door:
			var exit_node = astar_graph.get_exit_node(action.target_door)
			if current_low_level_action:
				current_low_level_action.exit(self)
			current_low_level_action = leave_action_controller
			current_low_level_action.enter(self, exit_node)
	
	else:
		current_high_level_action = null
		if not calculating_low_action:
			# Calculate best action
			calculate_action()


	# Check if we haven't stopped moving towards node
	# There are cases where we miss the next node by a bit and are still withing the bounding box
	if not path or path.is_empty():
		return
	
	if abs(controller.position.distance_to(astar_graph.tmhelper.to_world_position(path[path_index].to)) - last_dist) < 0.1:
		# Recalculate A*
		calculate_astar()

	elif path and not path.is_empty():
		last_dist = controller.position.distance_to(astar_graph.tmhelper.to_world_position(path[path_index].to))


func _process(delta):
	#Check if we have an action then act
	if not current_low_level_action and not calculating_low_action:
		calculate_action()

	elif current_low_level_action:
		# print("Executing action: ", current_low_level_action.name, " creature ", creature.name)
		current_low_level_action.execute(self)

		# If we have a target check if we've reached it
		if target and controller.position.distance_to(target) < detect_target_dist:
			target = null
			path = null
			on_target_reached.emit()
			
		# Check if we have a target then act
		if (not path or path.is_empty()) and not astar_ai.calculating_astar and target:
			calculate_astar()

		# Check if target node is still the same
		if path and not path.is_empty() and target and path[path.size() - 1].to != astar_graph.tmhelper.to_local_position(target):
			calculate_astar()

		# Check if we have a path then act
		if path and not path.is_empty():
			check_path_progress()
			calculate_movement()
		


func calculate_astar():
	if not astar_graph.astar_nodes:
		return
	if not target:
		return
	if controller.current_state == controller.fall_state:
		return
	
	var current_node = astar_graph.tmhelper.to_local_position(controller.position)
	var target_node = astar_graph.tmhelper.to_local_position(target)

	if current_node == target_node:
		target = null
		path = null
		on_target_reached.emit()
		return
	
	#DEBUG
	astar_graph.astar_on_going = []
	astar_graph.astar_target = astar_graph.tmhelper.to_world_position(target_node)
	astar_graph.queue_redraw()

	if current_node == null or target_node == null:
		return
	if not astar_graph.astar_nodes.has(current_node):
		# push_warning("Current node not found in astar graph | Creature: ", get_parent().name)
		on_current_node_missing.emit(creature)
		return

	path = []
	path_index = 0
	last_dist = 100000
	path = await astar_ai.astar(current_node, target_node, true) #DEBUG


# Async
func calculate_action():
	calculating_low_action = true

	var state = await low_level_state_manager.get_state(creature)
	var action = low_level_ai.calculate_action(state)

	if action is EatAction:
		if not low_level_state_manager.get_item_node(action.food):
			push_warning("Food not found | Creature: ", get_parent().name, " | Action: ", action)
			calculating_low_action = false
			return
		if current_low_level_action:
			current_low_level_action.exit(self)
		current_low_level_action = eat_action_controller
		current_low_level_action.enter(self, low_level_state_manager.get_item_node(action.food))

	elif action is FleeAction:
		if not low_level_state_manager.get_item_node(action.enemy):
			push_warning("Enemy not found | Creature: ", get_parent().name, " | Action: ", action)
			calculating_low_action = false
			return
		if current_low_level_action:
			current_low_level_action.exit(self)
		current_low_level_action = flee_action_controller
		current_low_level_action.enter(self, low_level_state_manager.get_item_node(action.enemy))

	elif action is AttackAction:
		if not low_level_state_manager.get_item_node(action.enemy):
			push_warning("Enemy not found | Creature: ", get_parent().name, " | Action: ", action)
			calculating_low_action = false
			return
		if current_low_level_action:
			current_low_level_action.exit(self)
		current_low_level_action = attack_action_controller
		current_low_level_action.enter(self, low_level_state_manager.get_item_node(action.enemy))

	elif action is RestAction:
		if current_low_level_action:
			current_low_level_action.exit(self)
		current_low_level_action = rest_action_controller
		current_low_level_action.enter(self)

	calculating_low_action = false

func on_action_finished():
	if current_low_level_action:
		current_low_level_action.exit(self)
	current_low_level_action = null

	if not calculating_low_action:
		calculate_action()


func check_path_progress(state = null):
	if not path:
		return

	#DEBUG
	astar_graph.astar_path = path
	astar_graph.queue_redraw()

	# Check if reached next node and update to next one
	if path_index < path.size() - 1 and path[path_index].to == astar_graph.tmhelper.to_local_position(controller.position):
		path_index += 1
		last_dist = 100000

	# Check if reached last node
	elif path_index == path.size() - 1 and path[path_index].to == astar_graph.tmhelper.to_local_position(controller.position):
		target = null
		path = null
		last_dist = 100000
		on_target_reached.emit()

	else:

		# Check if out of edge's bounding box by thickness
		# Disable for some seconds if jumping
		if controller.current_state == controller.fall_state or controller.current_state == controller.stun_state:
			return
		
		var node_a = astar_graph.tmhelper.to_world_position(path[path_index].from)
		var node_b = astar_graph.tmhelper.to_world_position(path[path_index].to)

		var bounding_box_center = (node_a + node_b) / 2
		var bounding_box_rot_1 = (node_a - bounding_box_center).angle()
		var bounding_box_rot_2 = (node_b - bounding_box_center).angle()
		# var bounding_box = [node_a, node_a, node_b, node_b]
		var bounding_box = [node_a + Vector2(bounding_box_margin, -bounding_box_margin).rotated(bounding_box_rot_1), 
			node_a + Vector2(bounding_box_margin, bounding_box_margin).rotated(bounding_box_rot_1), 
			node_b + Vector2(bounding_box_margin, -bounding_box_margin).rotated(bounding_box_rot_2),
			node_b + Vector2(bounding_box_margin, bounding_box_margin).rotated(bounding_box_rot_2)]

		astar_graph.creature_bounding_box = bounding_box #DEBUG
		astar_graph.queue_redraw()

		if not (controller.position.x < bounding_box.reduce(func(max_vec, vec): return vec if vec.x > max_vec.x else max_vec).x and \
			controller.position.x > bounding_box.reduce(func(min_vec, vec): return vec if vec.x < min_vec.x else min_vec).x and \
			controller.position.y < bounding_box.reduce(func(max_vec, vec): return vec if vec.y > max_vec.y else max_vec).y and \
			controller.position.y > bounding_box.reduce(func(min_vec, vec): return vec if vec.y < min_vec.y else min_vec).y):
				
				# Recalculate A*
				calculate_astar()


func calculate_movement():
	if not path:
		return
	
	var next_node = path[path_index].to

	match path[path_index].movement_type:
		Edge.MovementType.WALK: 
			walk(next_node)
		Edge.MovementType.CLIMB:
			climb(next_node)
		Edge.MovementType.CRAWL:
			crawl(next_node)
		Edge.MovementType.SWITCH_CLIMBING:
			switch_climbing(next_node)
		Edge.MovementType.SWITCH_CRAWL_WALK:
			switch_crawl_walk(next_node)
		Edge.MovementType.SWITCH_CRAWL_CLIMB:
			switch_crawl_climb(next_node)
		Edge.MovementType.JUMP:
			jump(next_node)
		Edge.MovementType.FALL:
			fall()


func walk(next_node):
	controller.queue_change_state(controller.walk_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func climb(next_node):
	controller.queue_change_state(controller.climb_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func crawl(next_node):
	controller.queue_change_state(controller.crawl_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func switch_climbing(next_node):
	controller.queue_change_state(controller.switch_climbing_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func switch_crawl_walk(next_node):
	controller.queue_change_state(controller.switch_crawl_walk_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func switch_crawl_climb(next_node):
	controller.queue_change_state(controller.switch_crawl_climb_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func jump(next_node):
	if controller.position.distance_to(astar_graph.tmhelper.to_world_position(next_node)) < unnecessary_jump_threshold:
		walk(next_node) #TODO maybe we need to check for climbing too?	
	elif controller.current_state != controller.fall_state:
		controller.queue_change_state(controller.jump_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})
	#TODO IMPORTANT Add alternative movement here, and probably add the same behaviour to switching movements once we figure it out

func fall():
	controller.queue_change_state(controller.fall_state, {"should grab": false})


# Actions
func eat(food):
	controller.queue_change_state(controller.eat_state, {"food": food})

func rest():
	controller.queue_change_state(controller.rest_state, {})

func attack(_target):
	controller.queue_change_state(controller.attack_state, {"target": _target})
