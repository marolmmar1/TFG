extends Node2D

class_name ZoneClass

# @onready var doors = $Doors.get_children()
@onready var zone_props = $ZoneProps #HACK not sure
@onready var tilemap = $TileMap
@onready var astar_graph: Node2D = $"AStarGraph"
@onready var low_level_state_manager: Node2D = $"LowLevelStateManager"

@onready var doors = $TileMap/Doors.get_children()
@onready var random_timer: Timer = $Randomicer
@onready var zone_tilemap: TileMap = $TileMap
@onready var random_wait : bool = true

enum ZoneType{REGULAR, LAIR}

var type = ZoneType.REGULAR
var threat_level: int
var food_amount: int
signal on_creature_enter(creature)


func get_all_creatures():
	return zone_props.get_children().filter(func(x): return x.is_in_group("Creature"))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	threat_level = randi_range(1, 3)
	food_amount = randi_range(1, 3)
	astar_graph.init(tilemap, self)
	low_level_state_manager.init(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if random_wait:
		random_wait = false
		randomize_zone()

func randomize_zone():
	#print(zone_tilemap.get_parent().get_name())
	random_timer.start()
	threat_level = randi_range(1, 3)
	food_amount = randi_range(1, 3)
	#print("Threat level: ", threat_level)
	#print("Food amount: ", food_amount)

	
func _on_randomicer_timeout():
	random_wait = true	

func _zone_value():
	var value  = (threat_level + food_amount)/2.0
	return roundf(value)

func _to_string():
	return self.name+", Type: " + ZoneType.keys()[type] + ", Threat level: " + str(threat_level) + ", Food amount: " + str(food_amount)
