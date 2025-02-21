extends Node

var tmhelper

func link_platform_nodes(astar_nodes, platform_nodes, platform_wall_nodes):

	var all_nodes = platform_nodes + platform_wall_nodes

	for i in range(all_nodes.size()):
		var node_a = all_nodes[i]
		for j in range(i + 1, all_nodes.size()):
			var node_b = all_nodes[j]
			if are_platforms_connected(node_a, node_b):
				# Add a bidirectional connection
				astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.WALK))
				astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.WALK))

func are_platforms_connected(node_a: Vector2i, node_b: Vector2i) -> bool:
	# Check if the nodes are in a horizontal line
	if node_a.y != node_b.y:
		return false

	# Get the direction from node_a to node_b
	var direction = Vector2i(0, 0)
	direction.x = 1 if node_b.x > node_a.x else -1

	# Check all tiles between node_a and node_b
	var current = node_a + direction
	while current != node_b:
		# Check if the tile below is terrain or a tunnel gate
		var below = current + Vector2i(0, 1)
		if not (tmhelper.is_terrain(below) or tmhelper.is_tunnel_gate_node(below)):
			return false  # No terrain or tunnel gate below

		# Check if the current tile itself is terrain
		if tmhelper.is_terrain(current):
			return false  # Terrain in the straight line between nodes

		current += direction

	return true

func link_wall_nodes(astar_nodes, wall_nodes, platform_wall_nodes, wall_corner_nodes):

	var all_nodes = wall_nodes + platform_wall_nodes + wall_corner_nodes

	for i in range(all_nodes.size()):
		var node_a = all_nodes[i]
		for j in range(i + 1, all_nodes.size()):
			var node_b = all_nodes[j]
			if are_walls_connected(node_a, node_b):
				# Add a bidirectional connection
				astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.CLIMB))
				astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.CLIMB))

func are_walls_connected(node_a: Vector2i, node_b: Vector2i) -> bool:
	# Check if the nodes are in a vertical straight line
	if node_a.x != node_b.x:
		return false  # Not in a vertical line

	# Get the direction from node_a to node_b
	var direction = Vector2i(0, 1 if node_b.y > node_a.y else -1)

	# Check all tiles between node_a and node_b
	# We allow a small amount of inconsistency for floating platforms and such
	var accumulated_inconsistency = 0
	var current = node_a + direction
	while current != node_b:
		# Check if the current tile itself is terrain
		if tmhelper.is_terrain(current):
			return false  # Terrain in the straight line between nodes

		# Determine the side with terrain (left or right)
		var left = current + Vector2i(-1, 0)
		var right = current + Vector2i(1, 0)

		var has_left_terrain = tmhelper.is_terrain(left) or tmhelper.is_tunnel_gate_node(left)
		var has_right_terrain = tmhelper.is_terrain(right) or tmhelper.is_tunnel_gate_node(right)

		# Ensure the side with terrain is consistent for both nodes
		if (has_left_terrain and not has_right_terrain) or (has_right_terrain and not has_left_terrain):
			# Check if the side matches for node_a and node_b
			var node_a_left = node_a + Vector2i(-1, 0)
			var node_a_right = node_a + Vector2i(1, 0)
			var node_b_left = node_b + Vector2i(-1, 0)
			var node_b_right = node_b + Vector2i(1, 0)

			var node_a_has_left_terrain = tmhelper.is_terrain(node_a_left) or tmhelper.is_tunnel_gate_node(node_a_left)
			var node_a_has_right_terrain = tmhelper.is_terrain(node_a_right) or tmhelper.is_tunnel_gate_node(node_a_right)
			var node_b_has_left_terrain = tmhelper.is_terrain(node_b_left) or tmhelper.is_tunnel_gate_node(node_a_left)
			var node_b_has_right_terrain = tmhelper.is_terrain(node_b_right) or tmhelper.is_tunnel_gate_node(node_a_left)

			if (has_left_terrain and not (node_a_has_left_terrain and node_b_has_left_terrain)) or \
			   (has_right_terrain and not (node_a_has_right_terrain and node_b_has_right_terrain)):
				accumulated_inconsistency += 1
				if accumulated_inconsistency > 1:
					return false  # Terrain side is not consistent
		else:
			accumulated_inconsistency += 1
			if accumulated_inconsistency > 1:
				return false  # Terrain side is not consistent

		current += direction

	return true

func link_intersection_and_tunnel_gate_nodes(astar_nodes, intersection_nodes, tunnel_gate_nodes, tunnel_end_nodes):

	var all_nodes = intersection_nodes + tunnel_gate_nodes + tunnel_end_nodes

	for i in range(all_nodes.size()):
		var node_a = all_nodes[i]
		for j in range(i + 1, all_nodes.size()):
			var node_b = all_nodes[j]
			if are_intersection_or_tunnel_gate_or_tunnel_end_connected(node_a, node_b):
				# Add a bidirectional connection
				astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.CRAWL))
				astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.CRAWL))

func are_intersection_or_tunnel_gate_or_tunnel_end_connected(node_a: Vector2i, node_b: Vector2i) -> bool:
	# Check if the nodes are in a straight line (horizontal or vertical)
	if node_a.x != node_b.x and node_a.y != node_b.y:
		return false  # Not in a straight line

	# Get the direction from node_a to node_b
	var direction = Vector2i(0, 0)
	if node_a.x == node_b.x:
		direction.y = 1 if node_b.y > node_a.y else -1
	else:
		direction.x = 1 if node_b.x > node_a.x else -1

	# Check all tiles between node_a and node_b
	var current = node_a + direction
	while current != node_b:
		# Check if the current tile itself is terrain
		if tmhelper.is_terrain(current):
			return false  # Terrain in the straight line between nodes

		current += direction

	return true

func link_platform_and_wall_nodes(astar_nodes, platform_nodes, platform_wall_nodes, wall_nodes):
	# Combine platform nodes and wall nodes into a single list
	var all_nodes = platform_nodes + platform_wall_nodes + wall_nodes

	for i in range(all_nodes.size()):
		var node_a = all_nodes[i]
		for j in range(i + 1, all_nodes.size()):
			var node_b = all_nodes[j]
			if tmhelper.get_adjacent_cells(node_a).has(node_b) and \
				(wall_nodes.has(node_a) or wall_nodes.has(node_b)):
				# Add a bidirectional connection
				astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.SWITCH_CLIMBING))
				astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.SWITCH_CLIMBING))

func link_tunnel_gate_nodes(astar_nodes, tunnel_gate_nodes, platform_nodes, wall_nodes, platform_wall_nodes):
	# Combine tunnel gate nodes, platform nodes, wall nodes, and platform wall nodes into a single list
	var all_nodes = tunnel_gate_nodes + platform_nodes + wall_nodes + platform_wall_nodes

	for i in range(all_nodes.size()):
		var node_a = all_nodes[i]
		for j in range(i + 1, all_nodes.size()):
			var node_b = all_nodes[j]
			if tmhelper.get_adjacent_cells(node_a).has(node_b) and \
				tunnel_gate_nodes.has(node_a) or tunnel_gate_nodes.has(node_b) and \
				(platform_nodes.has(node_a) or platform_nodes.has(node_b) or \
				wall_nodes.has(node_a) or wall_nodes.has(node_b) or \
				platform_wall_nodes.has(node_a) or platform_wall_nodes.has(node_b)):
				# Add a bidirectional connection depending on the source node
				if wall_nodes.has(node_b):
					astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.SWITCH_CRAWL_CLIMB))
					astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.SWITCH_CRAWL_CLIMB))
				else:
					astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.SWITCH_CRAWL_WALK))
					astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.SWITCH_CRAWL_WALK))

func link_platform_nodes_by_jump(astar_nodes, platform_nodes, vertical_jump_dist, horizontal_jump_dist):

	for i in range(platform_nodes.size()):
		var node_a = platform_nodes[i]
		for j in range(i + 1, platform_nodes.size()):
			var node_b = platform_nodes[j]

			var guard = false
			for edge in astar_nodes[node_a]:
				if edge.to == node_b:
					guard = true
			for edge in astar_nodes[node_b]:
				if edge.to == node_a:
					guard = true
			if guard:
				continue

			if are_platforms_connected_by_jump(node_a, node_b, vertical_jump_dist, horizontal_jump_dist):
				# Add a onedirectional connection
				astar_nodes[node_a].append(Edge.new(node_a, node_b, Edge.MovementType.JUMP))
			if are_platforms_connected_by_jump(node_b, node_a, vertical_jump_dist, horizontal_jump_dist):
				# Add a onedirectional connection
				astar_nodes[node_b].append(Edge.new(node_b, node_a, Edge.MovementType.JUMP))

func are_platforms_connected_by_jump(node_a: Vector2i, node_b: Vector2i, vertical_jump_dist, horizontal_jump_dist) -> bool:
	
	var dist = (Vector2.UP * vertical_jump_dist + Vector2.RIGHT * horizontal_jump_dist).length()

	# If higher or equal check for distance (y is - in Godot)
	if node_b.y <= node_a.y and (
		abs(node_b.y - node_a.y) > vertical_jump_dist or 
		abs(node_b.x - node_a.x) > horizontal_jump_dist or 
		(abs(node_b.y - node_a.y) > vertical_jump_dist/2 and abs(node_b.x - node_a.x) > horizontal_jump_dist/2)
		): # Wrong

		return false

	# If lower check for distance to same height
	if node_b.y > node_a.y and (Vector2(node_b.x, node_a.y) - Vector2(node_a)).length() > dist:
		return false

	#Check for obstacles
	var direction = (Vector2(node_b) - Vector2(node_a)).normalized()
	for i in range(1, dist):
		var current = Vector2(node_a) + direction * i
		current = Vector2i(round(current.x), round(current.y))
		if tmhelper.is_terrain(current):
			return false

	return true