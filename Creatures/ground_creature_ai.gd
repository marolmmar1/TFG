extends Node2D

@export_category("Debug") #DEBUG
@export var target: Node2D
@export var astar_node: Node2D
@export var detect_node_dist: float = 5
@export var unnecessary_jump_threshold: float = 25.0

var astar_graph
var controller
var path = []
var path_index = 0


func init(_astar, _controller):
	self.astar_graph = _astar
	self.controller = _controller


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


class AstarAINode:
	func _init(_node: Vector2i, _parent: AstarAINode, _cost: int):
		self.node = _node
		self.parent = _parent
		self.cost = _cost

	var node: Vector2i
	var parent: AstarAINode
	var cost: int


func astar(current_node: Vector2i, target_node: Vector2i) -> Array:
	var pending = []
	var explored = []

	var start_node = AstarAINode.new(current_node, null, 0)

	pending.append(start_node)

	while pending.size() > 0: #TODO prevent infinite loop and split process through ticks

		# #DEBUG
		# await get_tree().create_timer(0.25).timeout
		# astar_node.queue_redraw()

		var lowest_cost_node = null
		var lowest_cost = INF

		for node in pending:
			var cost = node_cost(node, AstarAINode.new(target_node, null, 0))
			if cost < lowest_cost:
				lowest_cost = cost
				lowest_cost_node = node

		pending.erase(lowest_cost_node)
		explored.append(lowest_cost_node)

		if lowest_cost_node.node == target_node:
			return build_path(start_node, lowest_cost_node)

		var neighbors = get_neighbors(lowest_cost_node.node)
		for neighbor in neighbors:
			if explored.filter(func(x): return x.node == neighbor).size() > 0:
				continue

			var pending_neighbor = pending.filter(func(x): return x.node == neighbor).pop_front()

			if not pending_neighbor:
				pending_neighbor = AstarAINode.new(neighbor, lowest_cost_node, 0)
				var cost = node_cost(lowest_cost_node, pending_neighbor)
				pending_neighbor.cost = cost
				pending.append(pending_neighbor)
				
			else:
				var cost = node_cost(lowest_cost_node, pending_neighbor)
				if cost < pending_neighbor.cost:
					pending_neighbor.parent = lowest_cost_node
					pending_neighbor.cost = cost

	return []

func node_cost(from: AstarAINode, to: AstarAINode) -> int:
	var heuristic = controller.position.distance_to(astar_graph.tmhelper.to_world_position(to.node))
	var movement_cost = 0
	if from.parent:
		movement_cost = from.cost
		
	return heuristic + movement_cost

func get_neighbors(node: Vector2i) -> Array:
	var neighbors = []

	# #DEBUG
	# astar_node.astar_on_going.append(astar_graph.tmhelper.to_world_position(node))
	
	for edge in astar_graph.astar_nodes[node]:
		neighbors.append(edge.to)

	return neighbors

func build_path(start_node: AstarAINode, end_node: AstarAINode) -> Array:
	var _path = []
	var current = end_node
	while current != start_node:
		if current.parent:
			for edge in astar_graph.astar_nodes[current.parent.node]:
				if edge.to == current.node:
					_path.append(edge)
					break
		current = current.parent

	_path.reverse()
	return _path

#TODO pass to higher AI
func tick():
	if not path:
		var current_node = get_closest_node(controller.position, 1000)
		var target_node = get_closest_node(target.position, 1000)

		# #DEBUG
		# astar_node.astar_target = astar_graph.tmhelper.to_world_position(target_node)
		# astar_node.queue_redraw()

		path_index = 0
		path = astar(current_node, target_node)


func _process(delta: float) -> void:
	if path:

		#DEBUG
		astar_node.astar_path = path
		astar_node.queue_redraw()

		if path_index < path.size() and path[path_index].to == get_closest_node(controller.position, detect_node_dist):
			path_index += 1

		calculate_movement()

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
			switch_climbing(next_node, path[path_index].from)
		Edge.MovementType.SWITCH_CRAWL_WALK:
			switch_crawl_walk(next_node, path[path_index].from)
		Edge.MovementType.SWITCH_CRAWL_CLIMB:
			switch_crawl_climb(next_node, path[path_index].from)
		Edge.MovementType.JUMP:
			jump(next_node)


func walk(next_node):
	if astar_graph.tmhelper.to_world_position(next_node).x > controller.position.x:
		controller.queue_change_state(controller.walk_state, {"direction": Vector2.RIGHT})
	else:
		controller.queue_change_state(controller.walk_state, {"direction": Vector2.LEFT})

func climb(next_node):
	controller.queue_change_state(controller.climb_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})

func crawl(next_node):
	if astar_graph.tmhelper.to_world_position(next_node).y > controller.position.y:
		controller.queue_change_state(controller.crawl_state, {"direction": Vector2.DOWN})
	elif astar_graph.tmhelper.to_world_position(next_node).y < controller.position.y:
		controller.queue_change_state(controller.crawl_state, {"direction": Vector2.UP})
	elif astar_graph.tmhelper.to_world_position(next_node).x > controller.position.x:
		controller.queue_change_state(controller.crawl_state, {"direction": Vector2.RIGHT})
	else:
		controller.queue_change_state(controller.crawl_state, {"direction": Vector2.LEFT})

func switch_climbing(next_node, source_node):
	controller.queue_change_state(controller.switch_climbing_state, {"target node": astar_graph.tmhelper.to_world_position(next_node), "source node": astar_graph.tmhelper.to_world_position(source_node)})

func switch_crawl_walk(next_node, source_node):
	controller.queue_change_state(controller.switch_crawl_walk_state, {"target node": astar_graph.tmhelper.to_world_position(next_node), "source node": astar_graph.tmhelper.to_world_position(source_node), \
	"current state": "crawl" if controller.current_state == controller.crawl_state else "walk"})

func switch_crawl_climb(next_node, source_node):
	controller.queue_change_state(controller.switch_crawl_climb_state, {"target node": astar_graph.tmhelper.to_world_position(next_node), "source node": astar_graph.tmhelper.to_world_position(source_node), \
	"current state": "crawl" if controller.current_state == controller.crawl_state else "climb"})

func jump(next_node):
	if controller.position.distance_to(astar_graph.tmhelper.to_world_position(next_node)) < unnecessary_jump_threshold:
		walk(next_node) #TODO maybe we need to check for climbing too?
	elif controller.current_state != controller.fall_state:
		controller.queue_change_state(controller.jump_state, {"target node": astar_graph.tmhelper.to_world_position(next_node)})
	#TODO IMPORTANT Add alternative movement here, and probably add the same behaviour to switching movements once we figure it out
