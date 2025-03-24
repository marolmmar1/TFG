extends Node

var tilemap: TileMap
var doors: Node2D
@onready var _raycast: RayCast2D = $"../RayCast2D"

func init(_tilemap, _doors):
	tilemap = _tilemap
	doors = _doors

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

func is_exit(cell: Vector2i) -> bool:
	var areas = get_areas_at_point(to_world_position(cell))
	for i in doors.get_children():
		if i in areas:
			return true
		
	return false

# https://www.reddit.com/r/godot/comments/1701wjw/deleted_by_user/
func get_areas_at_point(point:Vector2)->Array[Area2D]:  
	var areaArray:Array[Area2D]  

	var directSpace = tilemap.get_world_2d().direct_space_state  
  
	var pointParameters := PhysicsPointQueryParameters2D.new()  
 
	pointParameters.collide_with_areas = true  
	pointParameters.collide_with_bodies = false
	pointParameters.position = point    

	var collisions = directSpace.intersect_point(pointParameters)    

	for collisionDict in collisions:    
		var collider:Node2D = collisionDict["collider"]  

		if collider is Area2D:  
			areaArray.append(collider)                

	return areaArray  


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

func to_local_position(cell):
	# Don't know why
	var v = (tilemap.to_local(cell)) / (tilemap.scale.x * 2);
	v = Vector2i(floor(v.x), floor(v.y));
	return v

func raycast(from, to):
	_raycast.target_position = to_world_position(to) - to_world_position(from)
	_raycast.position = to_world_position(from)
	_raycast.enabled = true
	_raycast.force_update_transform()
	_raycast.force_raycast_update()
	var result = _raycast.get_collider()
	return result
