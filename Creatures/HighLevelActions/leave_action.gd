extends Node
class_name LeaveAction

# @onready var doors = $Doors.get_children()
@onready var zone_props = $ZoneProps #HACK not sure
@onready var tilemap = $TileMap
@onready var astar_graph: Node2D = $"AStarGraph"
@onready var low_level_state_manager: Node2D = $"LowLevelStateManager"


var target_door: Door

#assings the target door. Destination must be adjacent to current zone
func choose_target(current_zone: ZoneClass, destination: ZoneClass):
	for door in current_zone.doors:
		if door.other_side and door.other_side.get_parent().get_parent().get_parent() == destination:
			target_door = door
