extends Node

var jump_reliability_cost_mult: float = 2.0 # Defaults
var fall_reliability_cost_mult: float = 1.5
var threat_base_cost: float = 10.0

var astar_graph: Node2D
var global_astar_manager
var low_level_state_manager

var walk_speed
var climb_speed
var crawl_speed
var switch_climbing_speed
var switch_crawl_walk_speed
var switch_crawl_climb_speed

var calculating_astar = false
var astar_nodes = {}

class AstarAINode:
	func _init(_node: Vector2i, _parent: AstarAINode, _cost: int):
		self.node = _node
		self.parent = _parent
		self.cost = _cost

	var node: Vector2i
	var parent: AstarAINode
	var cost: float

func deep_copy_dict(dict):
	var new_dict = {}
	for key in dict:
		if typeof(dict[key]) == TYPE_DICTIONARY:
			new_dict[key] = deep_copy_dict(dict[key])
		elif typeof(dict[key]) == TYPE_ARRAY:
			new_dict[key] = dict[key].duplicate()
		else:
			new_dict[key] = dict[key]
	return new_dict


func astar(current_node: Vector2i, target_node: Vector2i, debug_mode = false) -> Array:
	calculating_astar = true

	astar_nodes = deep_copy_dict(astar_graph.astar_nodes)

	var pending = []
	var explored = []

	var start_node = AstarAINode.new(current_node, null, 0)

	pending.append(start_node)

	var iterations = 0
	while pending.size() > 0:
		
		iterations += 1
		if iterations > 3: #HACK
			global_astar_manager.add_loop(iterations)
			iterations = 0

		# Split process through multiple frames
		if not global_astar_manager.can_process_loop():
			await get_tree().process_frame
		
		#DEBUG
		if debug_mode:
			# await get_tree().create_timer(0.01).timeout
			astar_graph.queue_redraw()

		var lowest_cost_node = null
		var lowest_cost = INF

		# Get pending node with lowest calculated cost + heuristic (expected cost)
		for node in pending:
			var cost = node.cost + node_heuristic(node, AstarAINode.new(target_node, null, 0))
			if cost < lowest_cost:
				lowest_cost = cost
				lowest_cost_node = node

		#HACK not a good fix but I'm getting tired of this code throwing errors everytime I try something new elsewhere
		# The main problem comes from the astar algorithm trying to walk throw temporary nodes that have actually been deleted
		# I've already implemented lots of checks and techniques to avoid this happening but it's still possible
		# So if everything else fails, just return and try again in a few seconds
		if not astar_nodes.has(lowest_cost_node.node):
			# if not get_parent().controller.current_state == get_parent().controller.fall_state:
			# 	push_warning("Tried to access node not in astar graph | Creature: ", get_parent().get_parent().name, " | Node:", lowest_cost_node.node, \
			# 		" | Pending: ", pending.map(func(x): return x.node), " | Explored: ", explored.map(func(x): return x.node), " Start node: ", start_node.node)
						
			get_tree().create_timer(0.25).timeout.connect(func(): calculating_astar = false)
			return []
		
		# We're exploring this one
		pending.erase(lowest_cost_node)
		explored.append(lowest_cost_node)
		
		# Goal reached
		if lowest_cost_node.node == target_node:
			var _path = build_path(start_node, lowest_cost_node)
			calculating_astar = false
			return _path

		#DEBUG
		if debug_mode:
			astar_graph.astar_on_going.append(astar_graph.tmhelper.to_world_position(lowest_cost_node.node))
			# print("parent cost: ", lowest_cost_node.parent.cost if lowest_cost_node.parent else 0)
			# print("cost: ", lowest_cost_node.cost - lowest_cost_node.parent.cost if lowest_cost_node.parent else lowest_cost_node.cost)
			# print("heuristic: ", node_heuristic(lowest_cost_node, AstarAINode.new(target_node, null, 0)))
			# print("total: ", lowest_cost_node.cost + node_heuristic(lowest_cost_node, AstarAINode.new(target_node, null, 0)), "\n")

		var neighbors = get_neighbors(lowest_cost_node.node, current_node, target_node)
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

func get_neighbors(node: Vector2i, current_node: Vector2i, target_node: Vector2i) -> Array:
	var neighbors = []

	for edge in astar_nodes[node]:

		# Ignore temporary edges unless we're in start node or they lead to target node
		if edge.temporary and (edge.from != current_node or edge.to != target_node):
			continue

		# Ignore double temporary edges unless we're in start node and they lead to target node
		if edge.double_temporary and not (edge.from == current_node and edge.to == target_node):
			continue

		# This is stupid but sometimes happens
		if not astar_nodes.has(edge.to):
			continue
		
		neighbors.append(edge.to)

	return neighbors


# Calculate costs
func node_heuristic(from: AstarAINode, to: AstarAINode) -> float:
	var dist = astar_graph.tmhelper.to_world_position(from.node).distance_to(astar_graph.tmhelper.to_world_position(to.node))
	
	return dist


func node_cost(from: AstarAINode, to: AstarAINode) -> float:

	var parent_cost = 0
	if from.parent:
		parent_cost = from.cost

	var movement_cost = 0
	for edge in astar_nodes[from.node]:
		if edge.to == to.node:
			movement_cost = movement_cost(edge)
			break
		
	return movement_cost + parent_cost

func movement_cost(edge: Edge) -> float:
	var cost = 0
	cost = speed_cost(edge)
	cost = reliavility_cost(edge, cost)
	cost += threat_cost(edge)
	return cost

func speed_cost(edge: Edge) -> float:
	var dist = astar_graph.tmhelper.to_world_position(edge.from).distance_to(astar_graph.tmhelper.to_world_position(edge.to))
	# v = d / t, t = d / v
	#HACK we need a reference speed though I'm not sure where to get it from
	if edge.movement_type == Edge.MovementType.WALK:
		return dist / walk_speed * 100
	elif edge.movement_type == Edge.MovementType.CLIMB:
		return dist / climb_speed * 100
	elif edge.movement_type == Edge.MovementType.CRAWL:
		return dist / crawl_speed * 100
	elif edge.movement_type == Edge.MovementType.SWITCH_CLIMBING:
		return dist / switch_climbing_speed * 100
	elif edge.movement_type == Edge.MovementType.SWITCH_CRAWL_WALK:
		return dist / switch_crawl_walk_speed * 100
	elif edge.movement_type == Edge.MovementType.SWITCH_CRAWL_CLIMB:
		return dist / switch_crawl_climb_speed * 100
	
	return dist

func reliavility_cost(edge: Edge, base_cost: float) -> float:
	# Maybe use exponentials so that the cost changes more with distance
	if edge.movement_type == Edge.MovementType.JUMP:
		return base_cost * jump_reliability_cost_mult
	elif edge.movement_type == Edge.MovementType.FALL:
		return base_cost * fall_reliability_cost_mult

	return base_cost

func threat_cost(edge: Edge) -> float:
	var cost = 0
	for creature in low_level_state_manager.creatures:
		var dist_1 = creature.global_position.distance_to(astar_graph.tmhelper.to_world_position(edge.from))
		var dist_2 = creature.global_position.distance_to(astar_graph.tmhelper.to_world_position(edge.to))
		var dist = min(dist_1, dist_2)
		dist = max(dist, 1)

		cost += (low_level_state_manager.max_considerable_distance / dist) * low_level_state_manager.get_creature_tl(creature) * threat_base_cost
		
	return cost


func build_path(start_node: AstarAINode, end_node: AstarAINode) -> Array:
	var _path = []
	var current = end_node
	while current != start_node:
		if current.parent:
			if not astar_nodes.has(current.parent.node):
				# push_warning("Failed to build path | Creature: ", get_parent().get_parent().name)
				return []
			for edge in astar_nodes[current.parent.node]:
				if edge.to == current.node:
					_path.append(edge)
					break
		current = current.parent

	_path.reverse()
	return _path


func get_total_cost_from_path(path: Array) -> float:
	var total_cost = 0
	for edge in path:
		total_cost += movement_cost(edge)
	return total_cost
