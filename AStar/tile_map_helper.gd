extends Node

var tilemap: TileMap
@onready var _raycast: RayCast2D = $"../RayCast2D"

func is_terrain(cell):

	var tile_data = tilemap.get_cell_tile_data(0, cell)
	if tile_data:
		return tile_data.get_custom_data("Terrain")
	return false

func is_tunnel_gate_node(cell: Vector2i) -> bool:

	var tile_data = tilemap.get_cell_tile_data(0, cell)
	if tile_data:
		return tile_data.get_custom_data("Tunnel gate")
	return false

func is_adjacent_to_terrain(cell):

	for adjacent_cell in get_adjacent_cells(cell):
		if is_terrain(adjacent_cell):
			return true
	return false

func get_adjacent_cells(cell):

	var adjacent_cells = [
		cell + Vector2i(0, -1),  # Up
		cell + Vector2i(0, 1),   # Down
		cell + Vector2i(-1, 0),  # Left
		cell + Vector2i(1, 0),    # Right
		cell + Vector2i(-1, -1), # Top-Left
		cell + Vector2i(1, -1),  # Top-Right
		cell + Vector2i(-1, 1),  # Bottom-Left
		cell + Vector2i(1, 1)    # Bottom-Right

	]
	return adjacent_cells

func to_world_position(cell):
	return tilemap.to_global(tilemap.map_to_local(cell));

func raycast(from, to):
	_raycast.target_position = to_world_position(to) - to_world_position(from)
	_raycast.position = to_world_position(from)
	_raycast.enabled = true
	_raycast.force_update_transform()
	_raycast.force_raycast_update()
	var result = _raycast.get_collider()
	return result
