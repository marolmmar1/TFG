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
@onready var berry_spawner = $BerrySpawner

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
	random_timer.wait_time = randf_range(5, 10.0)
	food_amount = quantize(random_timer.wait_time,10.0)

func quantize(value, max_value)->int:
	var quantized_value = 3
	var threshold = max_value/3
	if value > 2*threshold:
		quantized_value = 1
	elif value > threshold:
		quantized_value = 2
	return quantized_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if random_wait:
		random_wait = false
		randomize_zone()

func randomize_zone():
	var berrys = zone_props.get_children().filter(func(x): return x.name.begins_with("Berry")).size()
	if berry_spawner != null:
		var slots = berry_spawner.get_children()
		var selector = range(0, slots.size()-1)
		while (berrys < slots.size() and (selector.size() >0)):
			var id= randi_range(0, selector.size()-1)
			slots[id].spawn()
			selector.remove_at(id)
			berrys += 1
	
func _on_randomicer_timeout():
	random_wait = true	

func _zone_value():
	var value = max(1, food_amount - threat_level + 1)
	return roundf(value)

func _to_string():
	return self.name+", Type: " + ZoneType.keys()[type] + ", Threat level: " + str(threat_level) + ", Food amount: " + str(food_amount)
