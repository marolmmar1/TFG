extends Node

@export var detect_node_dist: float = 5.0
@export var unnecessary_jump_threshold: float = 25.0
@export var jump_reliability_cost_mult: float = 1.5 #HACK possibly variables for the genetic algorithm variation lately
@export var fall_reliability_cost_mult: float = 1.25

var astar_graph: Node2D

var walk_speed
var climb_speed
var crawl_speed
var switch_climbing_speed
var switch_crawl_walk_speed
var switch_crawl_climb_speed

var calculating_astar = false

class AstarAINode:
	func _init(_node: Vector2i, _parent: AstarAINode, _cost: int):
		self.node = _node
		self.parent = _parent
		self.cost = _cost

	var node: Vector2i
	var parent: AstarAINode
	var cost: float


func astar(current_node: Vector2i, target_node: Vector2i) -> Array:
	calculating_astar = true

	var pending = []
	var explored = []

	var start_node = AstarAINode.new(current_node, null, 0)

	pending.append(start_node)

	while pending.size() > 0: #TODO prevent infinite loop and split process through ticks

		# #DEBUG
		await get_tree().create_timer(0.5).timeout
		astar_graph.queue_redraw()

		var lowest_cost_node = null
		var lowest_cost = INF

		# Get pending node with lowest calculated cost + heuristic (expected cost)
		for node in pending:
			var cost = node.cost + node_heuristic(node, AstarAINode.new(target_node, null, 0))
			if cost < lowest_cost:
				lowest_cost = cost
				lowest_cost_node = node

		# We're exploring this one
		pending.erase(lowest_cost_node)
		explored.append(lowest_cost_node)

		# Goal reached
		if lowest_cost_node.node == target_node:
			var _path = build_path(start_node, lowest_cost_node)
			calculating_astar = false
			return _path

		# #DEBUG
		astar_graph.astar_on_going.append(astar_graph.tmhelper.to_world_position(lowest_cost_node.node))
		print("cost: ", lowest_cost_node.cost)
		print("heuristic: ", node_heuristic(lowest_cost_node, AstarAINode.new(target_node, null, 0)))
		print("total: ", lowest_cost_node.cost + node_heuristic(lowest_cost_node, AstarAINode.new(target_node, null, 0)), "\n")

		var neighbors = get_neighbors(lowest_cost_node.node)
		for neighbor in neighbors:
			# Skip explored neighbors
			if explored.filter(func(x): return x.node == neighbor).size() > 0:
				continue

			var pending_neighbor = pending.filter(func(x): return x.node == neighbor).pop_front()

			# If not pending add the neighbor
			if not pending_neighbor:
				pending_neighbor = AstarAINode.new(neighbor, lowest_cost_node, 0)
				var cost = node_cost(lowest_cost_node, pending_neighbor)
				pending_neighbor.cost = cost
				pending.append(pending_neighbor)
				
			# If pending update neighbor cost if lower
			else:
				var cost = node_cost(lowest_cost_node, pending_neighbor)
				if cost < pending_neighbor.cost:
					pending_neighbor.parent = lowest_cost_node
					pending_neighbor.cost = cost

	return []

func get_neighbors(node: Vector2i) -> Array:
	var neighbors = []

	for edge in astar_graph.astar_nodes[node]:
		neighbors.append(edge.to)

	return neighbors


# Calculate costs
func node_heuristic(from: AstarAINode, to: AstarAINode) -> float:
	var dist = astar_graph.tmhelper.to_world_position(from.node).distance_to(astar_graph.tmhelper.to_world_position(to.node))
	
	# Divide by speed to put it in the same scale as movement cost. At first sight I don't think the actual dividing speed is important, we just want to lower the value
	return dist / walk_speed


func node_cost(from: AstarAINode, to: AstarAINode) -> float:

	var parent_cost = 0
	if from.parent:
		parent_cost = from.cost

	var movement_cost = 0
	for edge in astar_graph.astar_nodes[from.node]:
		if edge.to == to.node:
			movement_cost = speed_cost(edge)
			movement_cost = reliavility_cost(edge, movement_cost)
			break
		
	return movement_cost + parent_cost

func speed_cost(edge: Edge) -> float:
	var dist = astar_graph.tmhelper.to_world_position(edge.from).distance_to(astar_graph.tmhelper.to_world_position(edge.to))
	# v = d / t, t = d / v
	if edge.movement_type == Edge.MovementType.WALK:
		return dist / walk_speed
	elif edge.movement_type == Edge.MovementType.CLIMB:
		return dist / climb_speed
	elif edge.movement_type == Edge.MovementType.CRAWL:
		return dist / crawl_speed
	elif edge.movement_type == Edge.MovementType.SWITCH_CLIMBING:
		return dist / switch_climbing_speed
	elif edge.movement_type == Edge.MovementType.SWITCH_CRAWL_WALK:
		return dist / switch_crawl_walk_speed
	elif edge.movement_type == Edge.MovementType.SWITCH_CRAWL_CLIMB:
		return dist / switch_crawl_climb_speed
	
	return dist

func reliavility_cost(edge: Edge, cost: float) -> float:
	# Maybe use exponentials so that the cost changes more with distance
	if edge.movement_type == Edge.MovementType.JUMP:
		return cost * jump_reliability_cost_mult
	elif edge.movement_type == Edge.MovementType.FALL:
		return cost * fall_reliability_cost_mult

	return cost


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
