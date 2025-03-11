extends Node

@onready var randomizer_timer: Timer = $Randomizer_timer
@onready var data = $CreatureData
@onready var AI = $AI

var randomizer_wait: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	data.spawn(CreatureData.CreatureType.HERVIVORE, 100, 100, 100, 10, get_parent().get_parent())
	randomizer_wait = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	data._update_memory(data.current_zone)
	if randomizer_wait:
		randomizer_wait = false
		randomizer_timer.start()
		randomize_creature_state()



func _on_creature_data_death():
	print("samatao paco")
	queue_free()

func randomize_creature_state():
	data._set_health(randi_range(0, data.max_health))
	data._set_food(randi_range(0, data.max_food))
	data._set_stamina(randi_range(0, data.max_stamina))
	#print("Health: ", data.health, "\nFood: ",data.food, "\nStamina: ", data.stamina)


func _on_randomizer_timer_timeout():
	randomizer_wait = true
