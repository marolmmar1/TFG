extends Node

<<<<<<< HEAD:Creatures/HighLevelActions/leave_action.gd
=======
class_name Zone

# @onready var doors = $Doors.get_children()
@onready var zone_props = $ZoneProps #HACK not sure
@onready var tilemap = $TileMap
@onready var astar_graph: Node2D = $"AStarGraph"
@onready var low_level_state_manager: Node2D = $"LowLevelStateManager"

signal on_creature_enter(creature)
>>>>>>> origin/iter-2-ale:Zones/Zone.gd

func _ready():
<<<<<<< HEAD:Creatures/HighLevelActions/leave_action.gd
	pass # Replace with function body.
=======
	astar_graph.init(tilemap, self)
	low_level_state_manager.init(self)


func get_all_creatures():
	return zone_props.get_children().filter(func(x): return x.is_in_group("Creature"))
>>>>>>> origin/iter-2-ale:Zones/Zone.gd


func _process(delta):
	pass
