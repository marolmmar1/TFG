extends Node2D

class_name Zone

@onready var doors = $Doors.get_children()
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
	var creature = CreatureData.new()
	creature.spawn(CreatureData.CreatureType.HERVIVORE, 100, 100, 100, 10, {})
	creatures.add_child(creature)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if random_wait:
		random_wait = false
		#randomize_zone()
		for creaure in creatures.get_children():
			print(creaure)

func randomize_zone():
	print("Randomizing")
	random_timer.start()
	threat_level = randi_range(1, 5)
	food_amount = randi_range(1, 5)
	print("Threat level: ", threat_level)
	print("Food amount: ", food_amount)
	
func _on_randomicer_timeout():
	random_wait = true
