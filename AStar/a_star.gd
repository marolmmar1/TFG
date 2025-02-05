extends Node2D

@export var tilemap: TileMap
@export var vertical_jump_dist: int = 3
@export var horizontal_jump_dist: int = 4

var tmhelper
var nodes_helper
var link_helper

var astar_nodes = {}

var platform_nodes = []
var platform_wall_nodes = []
var wall_nodes = []
var wall_corner_nodes = []
var intersection_nodes = []
var tunnel_gate_nodes = []
var tunnel_end_nodes = []
var platform_fall_nodes = []

func _ready():
	tmhelper = $TileMapHelper
	tmhelper.tilemap = tilemap

	nodes_helper = $NodesHelper
	nodes_helper.tmhelper = tmhelper

	link_helper = $LinkHelper
	link_helper.tmhelper = tmhelper

	calculate_astar_nodes()

	calculate_platform_wall_nodes()
	calculate_platform_nodes()
	calculate_wall_nodes()
	calculate_wall_corner_nodes()
	calculate_intersection_nodes()
	calculate_tunnel_gate_nodes()
	calculate_tunnel_end_nodes()

	purge_astar_nodes()

	calculate_platform_fall_nodes()

	link_helper.link_platform_nodes(astar_nodes, platform_nodes, platform_wall_nodes)
	link_helper.link_wall_nodes(astar_nodes, wall_nodes, platform_wall_nodes, wall_corner_nodes)
	link_helper.link_intersection_and_tunnel_gate_nodes(astar_nodes, intersection_nodes, tunnel_gate_nodes, tunnel_end_nodes)
	link_helper.link_platform_and_wall_nodes(astar_nodes, platform_nodes, wall_nodes)
	link_helper.link_tunnel_gate_nodes(astar_nodes, tunnel_gate_nodes, platform_nodes, wall_nodes, platform_wall_nodes)
	link_helper.link_platform_nodes_by_jump(astar_nodes, platform_nodes, vertical_jump_dist, horizontal_jump_dist)

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
		var fall_node_left = nodes_helper.find_fall_node(astar_nodes, platform_nodes, node, Vector2i(-1, 0))
		var fall_node_right = nodes_helper.find_fall_node(astar_nodes, platform_nodes, node, Vector2i(1, 0))

		if fall_node_left != null:
			platform_fall_nodes.append(fall_node_left)
			astar_nodes[node].append(Edge.new(node, fall_node_left, Edge.MovementType.FALL))  # One-directional edge
		if fall_node_right != null:
			platform_fall_nodes.append(fall_node_right)
			astar_nodes[node].append(Edge.new(node, fall_node_right, Edge.MovementType.FALL))  # One-directional edge



func purge_astar_nodes():

	astar_nodes.clear()

	for node in platform_nodes:
		astar_nodes[node] = []
	for node in platform_wall_nodes:
		astar_nodes[node] = []
	for node in wall_nodes:
		astar_nodes[node] = []
	for node in wall_corner_nodes:
		astar_nodes[node] = []
	for node in intersection_nodes:
		astar_nodes[node] = []
	for node in tunnel_gate_nodes:
		astar_nodes[node] = []
	for node in tunnel_end_nodes:
		astar_nodes[node] = []


#DEBUG
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
				Edge.MovementType.SWITCH_AND_CRAWL:
					color = Color(1, 0, 1)
			draw_line(world_position_a, world_position_b, color, 2)

			if edge.movement_type == Edge.MovementType.FALL:
				draw_line(world_position_a, world_position_b, Color(1, 0, 0), 2)

				var direction = (world_position_b - world_position_a).normalized()
				var arrowhead1 = world_position_b - direction * 10 + direction.rotated(PI / 2) * 5
				var arrowhead2 = world_position_b - direction * 10 - direction.rotated(PI / 2) * 5
				draw_line(world_position_b, arrowhead1, Color(1, 0, 0), 2)
				draw_line(world_position_b, arrowhead2, Color(1, 0, 0), 2)

			if edge.movement_type == Edge.MovementType.JUMP:
				draw_line(world_position_a, world_position_b, Color(0, 1, 1), 2)

				var direction = (world_position_b - world_position_a).normalized()
				var arrowhead1 = world_position_b - direction * 10 + direction.rotated(PI / 2) * 5
				var arrowhead2 = world_position_b - direction * 10 - direction.rotated(PI / 2) * 5
				draw_line(world_position_b, arrowhead1, Color(0, 1, 1), 2)
				draw_line(world_position_b, arrowhead2, Color(0, 1, 1), 2)

