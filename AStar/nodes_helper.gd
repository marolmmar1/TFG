extends Node

var tmhelper

func is_platform_node(cell: Vector2i, platform_wall_nodes) -> bool:
	# Check if there is terrain directly below (0, 1)
	var below = cell + Vector2i(0, 1)
	if not tmhelper.is_terrain(below):
		return false

	# Check if there is terrain on one side below but not the other
	var below_left = cell + Vector2i(-1, 1)
	var below_right = cell + Vector2i(1, 1)

	var has_left_below_terrain = tmhelper.is_terrain(below_left)
	var has_right_below_terrain = tmhelper.is_terrain(below_right)

	# Platform node must have terrain on one side but not the other
	if not ((has_left_below_terrain and not has_right_below_terrain) or (has_right_below_terrain and not has_left_below_terrain)):
		return false

	# Check if there is a non-terrain tile directly above (0, -1)
	var above = cell + Vector2i(0, -1)
	if tmhelper.is_terrain(above):
		return false

	if platform_wall_nodes.has(cell):
		return false

	return true


func is_platform_wall_node(cell: Vector2i) -> bool:
	# Check if there is terrain directly below (0, 1)
	var below = cell + Vector2i(0, 1)
	if not tmhelper.is_terrain(below):
		return false

	# Check if there is terrain on one side below (either -1,1 or 1,1)
	var below_left = cell + Vector2i(-1, 1)
	var below_right = cell + Vector2i(1, 1)

	var has_left_below_terrain = tmhelper.is_terrain(below_left)
	var has_right_below_terrain = tmhelper.is_terrain(below_right)

	# Must have terrain on one side below
	if not (has_left_below_terrain or has_right_below_terrain):
		return false

	# Check if there is terrain on either the left or right side
	var left = cell + Vector2i(-1, 0)
	var right = cell + Vector2i(1, 0)

	var has_left_terrain = tmhelper.is_terrain(left) or is_tunnel_gate_node(left)
	var has_right_terrain = tmhelper.is_terrain(right) or is_tunnel_gate_node(right)

	if not (has_left_terrain or has_right_terrain):
		return false

	# Check if there is a non-terrain tile directly above (0, -1)
	var above = cell + Vector2i(0, -1)
	if tmhelper.is_terrain(above):
		return false

	# Check if there are non-terrain tiles above-left or above-right (or both)
	var above_left = cell + Vector2i(-1, -1)
	var above_right = cell + Vector2i(1, -1)

	var has_above_left_non_terrain = not tmhelper.is_terrain(above_left)
	var has_above_right_non_terrain = not tmhelper.is_terrain(above_right)

	# Must have at least one non-terrain tile above-left or above-right
	return has_above_left_non_terrain or has_above_right_non_terrain

func is_wall_node(cell: Vector2i) -> bool:

	var left = cell + Vector2i(-1, 0)
	var right = cell + Vector2i(1, 0)

	var has_left_terrain = tmhelper.is_terrain(left)
	var has_right_terrain = tmhelper.is_terrain(right)

	# Must have terrain on either the left or right side
	if not (has_left_terrain or has_right_terrain):
		return false

	var below_left = cell + Vector2i(-1, 1)
	var above_left = cell + Vector2i(-1, -1)
	var below_right = cell + Vector2i(1, 1)
	var above_right = cell + Vector2i(1, -1)

	var c = 0

	# Check if there is terrain on the side below or above (left or right) and non terrain in the other direction
	# If there's terrain on both sides, there mustn't be above or below one of those (platforms with more than one depth are prohibited next to walls)
	if has_left_terrain:
		if tmhelper.is_terrain(below_left) and tmhelper.is_terrain(above_left):
			return false
		if tmhelper.is_terrain(below_left) or tmhelper.is_terrain(above_left):
			c += 1
	if has_right_terrain:
		if tmhelper.is_terrain(below_right) and tmhelper.is_terrain(above_right):
			return false
		if tmhelper.is_terrain(below_right) or tmhelper.is_terrain(above_right):
			c += 1
	if c != 1:
		return false

	return true

func is_wall_corner_node(cell: Vector2i) -> bool:
	# Check if there is terrain on either the left or right side
	var left = cell + Vector2i(-1, 0)
	var right = cell + Vector2i(1, 0)

	var has_left_terrain = tmhelper.is_terrain(left)
	var has_right_terrain = tmhelper.is_terrain(right)

	# Must have terrain on either the left or right side, but not both
	if not (has_left_terrain or has_right_terrain) or (has_left_terrain and has_right_terrain):
		return false

	# Check if there is terrain above (0, -1)
	var above = cell + Vector2i(0, -1)
	if not tmhelper.is_terrain(above):
		return false

	# Check if there is terrain between the side and above
	if has_left_terrain:
		var above_left = cell + Vector2i(-1, -1)
		if not tmhelper.is_terrain(above_left):
			return false
	elif has_right_terrain:
		var above_right = cell + Vector2i(1, -1)
		if not tmhelper.is_terrain(above_right):
			return false

	# Check if below and the other side are empty (non-terrain)
	var below = cell + Vector2i(0, 1)
	if tmhelper.is_terrain(below):
		return false

	if has_left_terrain:
		if tmhelper.is_terrain(right):
			return false
	elif has_right_terrain:
		if tmhelper.is_terrain(left):
			return false

	return true

func is_intersection_node(cell: Vector2i) -> bool:
	# Check all four corners for terrain
	var top_left = cell + Vector2i(-1, -1)
	var top_right = cell + Vector2i(1, -1)
	var bottom_left = cell + Vector2i(-1, 1)
	var bottom_right = cell + Vector2i(1, 1)

	if not (
		tmhelper.is_terrain(top_left) and
		tmhelper.is_terrain(top_right) and
		tmhelper.is_terrain(bottom_left) and
		tmhelper.is_terrain(bottom_right)
	):
		return false

	# Check adjacent non-terrain tiles
	var adjacent_cells = [
		cell + Vector2i(0, -1),  # Up
		cell + Vector2i(0, 1),   # Down
		cell + Vector2i(-1, 0),  # Left
		cell + Vector2i(1, 0)    # Right
	]

	var non_terrain_adjacent = []
	for adjacent_cell in adjacent_cells:
		if not tmhelper.is_terrain(adjacent_cell):
			non_terrain_adjacent.append(adjacent_cell)

	# Must have at least two adjacent non-terrain tiles
	if non_terrain_adjacent.size() < 2:
		return false

	# Ensure the non-terrain tiles are not in a straight line (up/down or left/right) if just 2 tiles
	if non_terrain_adjacent.size() == 2:
		var is_straight_line = (
			(non_terrain_adjacent.has(cell + Vector2i(0, -1)) and non_terrain_adjacent.has(cell + Vector2i(0, 1))) or  # Up and Down
			(non_terrain_adjacent.has(cell + Vector2i(-1, 0)) and non_terrain_adjacent.has(cell + Vector2i(1, 0)))     # Left and Right
		)

		if is_straight_line:
			return false

	return true

func is_tunnel_gate_node(cell: Vector2i) -> bool:
	return tmhelper.is_tunnel_gate_node(cell)

func is_tunnel_end_node(cell: Vector2i) -> bool:
	# Check if the center tile is not terrain
	if tmhelper.is_terrain(cell):
		return false

	# Check if there's a non terrain tile
	var adjacent_cells = [
		cell + Vector2i(0, -1),  # Up
		cell + Vector2i(0, 1),   # Down
		cell + Vector2i(-1, 0),  # Left
		cell + Vector2i(1, 0)    # Right
	]

	var terrain_count = 0
	for adjacent_cell in adjacent_cells:
		if tmhelper.is_terrain(adjacent_cell):
			terrain_count += 1

	if terrain_count != 3:
		return false

	# Check if all but one adjacent tiles are terrain
	adjacent_cells = tmhelper.get_adjacent_cells(cell)

	terrain_count = 0
	for adjacent_cell in adjacent_cells:
		if tmhelper.is_terrain(adjacent_cell):
			terrain_count += 1

	if terrain_count != 7:
		return false

	return true

func find_fall_node(astar_nodes: Dictionary, platform_nodes, start_cell: Vector2i, direction: Vector2i):
	var current = start_cell + direction
	for i in range(20): #Just to avoid infinite loops
		# Check if the current cell is terrain
		if tmhelper.is_terrain(current) or tmhelper.is_tunnel_gate_node(current):
			# The fall node is the cell above the terrain
			var fall_node = current + Vector2i(0, -1)
			# Ensure the fall node is not already in the A* nodes or is a platform node
			if not astar_nodes.has(fall_node) or platform_nodes.has(fall_node):
				if fall_node.y - start_cell.y > 1:
					return fall_node
				else:
					return null
			else:
				return null

		# Move down
		current += Vector2i(0, 1)

		# Stop if we go out of bounds
		if not tmhelper.tilemap.get_used_rect().has_point(current):
			return null
