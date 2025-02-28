extends Node2D

@export var detect_node_dist: float = 30.0 # Tile size
@export var unnecessary_jump_threshold: float = 25.0

@onready var astar_ai = $AstarAI

var astar_graph: Node2D
var controller
var path = []
var path_index = 0
#DEBUG
var target


func init(_astar, _controller):
	self.astar_graph = _astar
	self.controller = _controller

	astar_ai.astar_graph = astar_graph

	astar_ai.walk_speed = controller.find_child("Walk").speed
	astar_ai.climb_speed = controller.find_child("Climb").speed
	astar_ai.crawl_speed = controller.find_child("Crawl").speed
	astar_ai.switch_climbing_speed = controller.find_child("SwitchClimbing").speed
	astar_ai.switch_crawl_walk_speed = controller.find_child("SwitchCrawlWalk").speed
	astar_ai.switch_crawl_climb_speed = controller.find_child("SwitchCrawlClimb").speed


func get_closest_node(point: Vector2, threshold: float):
	var closest_point = null
	var closest_dist = INF
	for node in astar_graph.astar_nodes:
		var dist = point.distance_to(astar_graph.tmhelper.to_world_position(node))
		if dist < closest_dist:
			closest_dist = dist
			if closest_dist < threshold:
				closest_point = node
	return closest_point


#TODO pass to higher AI
func tick():
	if not path and not astar_ai.calculating_astar:

		if not target:
			return

		if not astar_graph.astar_nodes:
			return

		var current_node = get_closest_node(controller.position, 30)
		var target_node = get_closest_node(target, 30)

		# #DEBUG
		astar_graph.astar_on_going = []
		astar_graph.astar_target = astar_graph.tmhelper.to_world_position(target_node)
		astar_graph.queue_redraw()

		if current_node == null or target_node == null:
			return

		path_index = 0
		path = await astar_ai.astar(current_node, target_node) #DEBUG


func _process(delta: float) -> void:
	if path:

		#DEBUG
		astar_graph.astar_path = path
		astar_graph.queue_redraw()

		calculate_movement()

		if path_index < path.size() - 1 and path[path_index].to == get_closest_node(controller.position, detect_node_dist):
			path_index += 1

		elif path_index == path.size() - 1 and path[path_index].to == get_closest_node(controller.position, detect_node_dist):
			target = null
			print("REACHED GOAL")
			path = []

		#TODO check if out of edge's bounding box by thickness
		# Disable for some seconds if jumping


func calculate_movement():	
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
