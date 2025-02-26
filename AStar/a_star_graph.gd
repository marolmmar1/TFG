extends Node2D

@export var tilemap: TileMap
@export var doors: Node2D
@export var horizontal_jump_dist: int = 4
@export var vertical_jump_dist: int = 3
@export var max_fall_height: int = 15

var tmhelper
var nodes_helper
var link_helper

var astar_nodes = {}

var platform_nodes = []
var platform_wall_nodes = []
var wall_nodes = []
var wall_grab_nodes = []
var wall_corner_nodes = []
var intersection_nodes = []
var tunnel_gate_nodes = []
var tunnel_end_nodes = []
var platform_fall_nodes = []

#DEBUG
var update_nodes = []

func _ready():
	# Godot needs a frame to set up the tilemap collisions in memory
	await get_tree().process_frame

	tmhelper = $TileMapHelper
	tmhelper.tilemap = tilemap
	tmhelper.doors = doors

	nodes_helper = $NodesHelper
	nodes_helper.tmhelper = tmhelper

	link_helper = $LinkHelper
	link_helper.tmhelper = tmhelper

	calculate_astar_nodes()

	calculate_platform_wall_nodes()
	calculate_platform_nodes()
	calculate_wall_nodes()
	calculate_wall_grab_nodes()
	calculate_wall_corner_nodes()
	calculate_intersection_nodes()
	calculate_tunnel_gate_nodes()
	calculate_tunnel_end_nodes()

	purge_and_fill_astar_nodes()
	# (This one requires to have all non-movement nodes purged)
	calculate_platform_fall_nodes()

	link_helper.link_platform_nodes(astar_nodes, platform_nodes, platform_wall_nodes, platform_fall_nodes)
	link_helper.link_wall_nodes(astar_nodes, wall_nodes, platform_wall_nodes, wall_corner_nodes, wall_grab_nodes)
	link_helper.link_intersection_and_tunnel_gate_nodes(astar_nodes, intersection_nodes, tunnel_gate_nodes, tunnel_end_nodes)
	link_helper.link_platform_and_wall_nodes(astar_nodes, platform_nodes, wall_nodes, wall_grab_nodes)
	link_helper.link_tunnel_gate_nodes(astar_nodes, tunnel_gate_nodes, platform_nodes, wall_nodes, platform_wall_nodes)
	link_helper.link_nodes_by_jump(astar_nodes, platform_nodes, wall_grab_nodes, platform_fall_nodes, vertical_jump_dist, horizontal_jump_dist, max_fall_height)
	link_helper.link_nodes_by_fall(astar_nodes, platform_nodes, wall_grab_nodes, platform_wall_nodes, platform_fall_nodes, max_fall_height)

	delete_isolated_nodes()

	queue_redraw()


func add_node(node_pos, update_radius):
	var node = tmhelper.to_local_position(node_pos)

	if tmhelper.is_terrain(node) or not tmhelper.is_adjacent_to_terrain(node):
		return

	if astar_nodes.has(node):
		pass
	elif nodes_helper.is_mid_platform_node(node):
		astar_nodes[node] = []
		platform_nodes.append(node)
	elif nodes_helper.is_mid_wall_node(node):
		astar_nodes[node] = []
		wall_nodes.append(node)
	elif nodes_helper.is_mid_tunnel_node(node):
		astar_nodes[node] = []
		intersection_nodes.append(node)


	update_nodes = []
	var update_platform_nodes = []
	var update_platform_wall_nodes = []
	var update_wall_nodes = []
	var update_wall_corner_nodes = []
	var update_wall_grab_nodes = []
	var update_intersection_nodes = []
	var update_tunnel_gate_nodes = []
	var update_tunnel_end_nodes = []
	var update_platform_fall_nodes = []

	for n in astar_nodes:
		if n.distance_to(node) <= update_radius:
			update_nodes.append(n)

			for edge in astar_nodes[n]:
				if update_nodes.has(edge.to) and not update_nodes.has(edge.from):
					astar_nodes[n].erase(edge)

			if platform_nodes.has(n):
				update_platform_nodes.append(n)
			if platform_wall_nodes.has(n):
				update_platform_wall_nodes.append(n)
			if wall_nodes.has(n):
				update_wall_nodes.append(n)
			if wall_corner_nodes.has(n):
				update_wall_corner_nodes.append(n)
			if wall_grab_nodes.has(n):
				update_wall_grab_nodes.append(n)
			if intersection_nodes.has(n):
				update_intersection_nodes.append(n)
			if tunnel_gate_nodes.has(n):
				update_tunnel_gate_nodes.append(n)
			if tunnel_end_nodes.has(n):
				update_tunnel_end_nodes.append(n)
			if platform_fall_nodes.has(n):
				update_platform_fall_nodes.append(n)
			
	link_helper.link_platform_nodes(astar_nodes, update_platform_nodes, update_wall_nodes, update_platform_fall_nodes)
	link_helper.link_wall_nodes(astar_nodes, update_wall_nodes, update_platform_wall_nodes, update_wall_corner_nodes, update_wall_grab_nodes)
	link_helper.link_intersection_and_tunnel_gate_nodes(astar_nodes, update_intersection_nodes, update_tunnel_gate_nodes, update_tunnel_end_nodes)
	link_helper.link_platform_and_wall_nodes(astar_nodes, update_platform_nodes, update_wall_nodes, update_wall_grab_nodes)
	link_helper.link_tunnel_gate_nodes(astar_nodes, update_tunnel_gate_nodes, update_platform_nodes, update_wall_nodes, update_platform_wall_nodes)
	link_helper.link_nodes_by_jump(astar_nodes, update_platform_nodes, update_wall_grab_nodes, update_platform_fall_nodes, vertical_jump_dist, horizontal_jump_dist, max_fall_height)
	link_helper.link_nodes_by_fall(astar_nodes, update_platform_nodes, update_wall_grab_nodes, update_platform_wall_nodes, update_platform_fall_nodes, max_fall_height)

	queue_redraw()


func calculate_astar_nodes():

	var used_cells = tilemap.get_used_cells(0)

	for cell in used_cells:
		if not tmhelper.is_terrain(cell) and tmhelper.is_adjacent_to_terrain(cell):
			astar_nodes[cell] = null

func calculate_platform_nodes():
	for node in astar_nodes:
		if nodes_helper.is_platform_node(node, platform_wall_nodes):
			platform_nodes.append(node)

func calculate_platform_wall_nodes():
	for node in astar_nodes:
		if nodes_helper.is_platform_wall_node(node):
			platform_wall_nodes.append(node)

func calculate_wall_nodes():
	for node in astar_nodes:
		if nodes_helper.is_wall_node(node):
			wall_nodes.append(node)

func calculate_wall_grab_nodes():
	for node in astar_nodes:
		if nodes_helper.is_wall_grab_node(node):
			wall_nodes.erase(node)
			wall_grab_nodes.append(node)

func calculate_wall_corner_nodes():
	for node in astar_nodes:
		if nodes_helper.is_wall_corner_node(node):
			wall_corner_nodes.append(node)

func calculate_intersection_nodes():
	for node in astar_nodes:
		if nodes_helper.is_intersection_node(node):
			intersection_nodes.append(node)

func calculate_tunnel_gate_nodes():
	for node in astar_nodes:
		if nodes_helper.is_tunnel_gate_node(node):
			tunnel_gate_nodes.append(node)

func calculate_tunnel_end_nodes():
	for node in astar_nodes:
		if nodes_helper.is_tunnel_end_node(node):
			tunnel_end_nodes.append(node)

func calculate_platform_fall_nodes():
	for node in platform_nodes:
		# Check left and right for fall nodes
		var fall_node_left = nodes_helper.find_fall_node(astar_nodes, node, Vector2i(-1, 0), max_fall_height)
		var fall_node_right = nodes_helper.find_fall_node(astar_nodes, node, Vector2i(1, 0), max_fall_height)

		if fall_node_left != null:
			platform_fall_nodes.append(fall_node_left)
		if fall_node_right != null:
			platform_fall_nodes.append(fall_node_right)

	for node in platform_fall_nodes:
		astar_nodes[node] = []


func purge_and_fill_astar_nodes():

	astar_nodes.clear()

	for node in platform_nodes:
		astar_nodes[node] = []
	for node in platform_wall_nodes:
		astar_nodes[node] = []
	for node in wall_nodes:
		astar_nodes[node] = []
	for node in wall_grab_nodes:
		astar_nodes[node] = []
	for node in wall_corner_nodes:
		astar_nodes[node] = []
	for node in intersection_nodes:
		astar_nodes[node] = []
	for node in tunnel_gate_nodes:
		astar_nodes[node] = []
	for node in tunnel_end_nodes:
		astar_nodes[node] = []
	

# Delete nodes if not connected to an exit node
func delete_isolated_nodes():
	var exits = []
	for node in astar_nodes:
		if tmhelper.is_exit(node):
			exits.append(node)

	assert(exits.size() > 0, "No exit nodes found")

	var to_delete = []

	for node in astar_nodes:
		if exits.has(node):
			continue

		var connected = dfs(node, astar_nodes)
		var ok = false
		for exit in exits:
			if connected.has(exit):
				ok = true
				break
				
		if not ok:
			to_delete.append(node)
		
	# Avoid array resize during iteration
	for node in to_delete:
		astar_nodes.erase(node)
		
		platform_nodes.erase(node)
		platform_wall_nodes.erase(node)
		wall_nodes.erase(node)
		wall_grab_nodes.erase(node)
		wall_corner_nodes.erase(node)
		intersection_nodes.erase(node)
		tunnel_gate_nodes.erase(node)
		tunnel_end_nodes.erase(node)
		platform_fall_nodes.erase(node)


# Depth-first search to find all connected nodes
func dfs(start_node, nodes):
	var visited = []
	var stack = [start_node]
	while stack.size() > 0:
		var node = stack.pop_back()
		if visited.has(node):
			continue
		visited.append(node)
		for edge in nodes[node]:
			if not visited.has(edge.to):
				stack.append(edge.to)
	return visited


#DEBUG
var astar_on_going = []
var astar_target
var astar_path = []

func _draw():
		
	for node in platform_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(0, 0, 1))
	
	for node in platform_wall_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(1, 0, 0))

	for node in wall_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(1, 1, 0))

	for node in wall_grab_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(0.5, 0.5, 0.5))

	for node in wall_corner_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(1, 0, 1))

	for node in intersection_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(0, 1, 0))

	for node in tunnel_gate_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(1, 0.5, 0))

	for node in tunnel_end_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(0, 0, 0))

	for node in platform_fall_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 5, Color(0, 1, 1))


	for node in astar_nodes:
		var world_position_a = tmhelper.to_world_position(node)
		for edge in astar_nodes[node]:
			var world_position_b = tmhelper.to_world_position(edge.to)
			var color: Color
			match edge.movement_type:
				Edge.MovementType.WALK:
					color = Color(0, 1, 0)
				Edge.MovementType.CLIMB:
					color = Color(1, 0.5, 0)
				Edge.MovementType.CRAWL:
					color = Color(0.5, 0.5, 1)
				Edge.MovementType.SWITCH_CLIMBING:
					color = Color(1, 1, 1)
				Edge.MovementType.SWITCH_CRAWL_WALK:
					color = Color(1, 0, 1)
				Edge.MovementType.SWITCH_CRAWL_CLIMB:
					color = Color(1, 0, 0.5)
			draw_line(world_position_a, world_position_b, color, 2)

			if edge.movement_type == Edge.MovementType.JUMP:
				draw_line(world_position_a, world_position_b, Color(0, 1, 1), 2)

				var direction = (world_position_b - world_position_a).normalized()
				var arrowhead1 = world_position_b - direction * 10 + direction.rotated(PI / 2) * 5
				var arrowhead2 = world_position_b - direction * 10 - direction.rotated(PI / 2) * 5
				draw_line(world_position_b, arrowhead1, Color(0, 1, 1), 2)
				draw_line(world_position_b, arrowhead2, Color(0, 1, 1), 2)

			if edge.movement_type == Edge.MovementType.FALL:
				draw_line(world_position_a, world_position_b, Color(1, 0, 0), 2)

				var direction = (world_position_b - world_position_a).normalized()
				var arrowhead1 = world_position_b - direction * 10 + direction.rotated(PI / 2) * 5
				var arrowhead2 = world_position_b - direction * 10 - direction.rotated(PI / 2) * 5
				draw_line(world_position_b, arrowhead1, Color(1, 0, 0), 2)
				draw_line(world_position_b, arrowhead2, Color(1, 0, 0), 2)

	if astar_target:
		draw_circle(astar_target, 10, Color(0, 1, 0))
	
	for i in astar_on_going:
		draw_circle(i, 10, Color(1, 0, 0))

	for edge in astar_path:
		var world_position_a = tmhelper.to_world_position(edge.from)
		var world_position_b = tmhelper.to_world_position(edge.to)
		draw_line(world_position_a, world_position_b, Color(0, 0, 0), 2)

	for node in update_nodes:
		var world_position = tmhelper.to_world_position(node)
		draw_circle(world_position, 2.5, Color(0, 0, 0))