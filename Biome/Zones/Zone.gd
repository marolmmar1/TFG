extends Node

class_name ZoneClass

@onready var doors = $TileMap/Doors.get_children()
@onready var random_timer: Timer = $Randomicer
@onready var zone_tilemap: TileMap = $TileMap
@onready var creatures: Node2D = $Creatures
@onready var random_wait : bool = true

enum ZoneType{REGULAR, LAIR}

var type = ZoneType.REGULAR
var threat_level: int
var food_amount: int

# Called when the node enters the scene tree for the first time.
func _ready():
	threat_level = randi_range(1, 3)
	food_amount = randi_range(1, 3)


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
	var value  = (threat_level + food_amount)/2
	return roundf(value)

func _to_string():
	return "Type: " + ZoneType.keys()[type] + "\nThreat level: " + str(threat_level) + "\nFood amount: " + str(food_amount)