extends Node

class_name CreatureData

enum CreatureType{HERVIVORE, CARNIVORE, OMNIVORE}

var controller
var creature

var type: CreatureType
var max_health: float
var max_food: float
var max_stamina: float
var attack_power: float
var food_value: float
var memory: Dictionary
#{zone: zone_value, "zones":[zone, ..., zone], "edges":[[zone,zone],...,[zone,zone]]]} 
var current_zone: ZoneClass

var food_depletion_rate
var health_starving_rate
var health_regen_rate
var forced_rest_time
var stamina_regen_rate

var dead := false

signal Death

var health: float:
	get:
		return health
	set(value):
		if (value<=0 and not dead):
			dead = true
			on_death.emit()
			health = 0
		if (value>=max_health):
			health = max_health
		else:
			health = value

var food: float:
	get:
		return food
	set(value):
		food = clamp(value, 0, max_food)

var stamina: float:
	get:
		return stamina
	set(value):
		stamina = clamp(value, 0, max_stamina)

signal on_death()

func init(_creature, _controller, _food_depletion_rate, _health_starving_rate, _health_regen_rate, _forced_rest_time, _stamina_regen_rate, _max_health, _max_food, _max_stamina, _attack_power, _current_zone: ZoneClass):
	creature = _creature
	controller = _controller
	
	max_health = _max_health
	max_food = _max_food
	max_stamina = _max_stamina
	attack_power = _attack_power
	food_depletion_rate = _food_depletion_rate
	health_starving_rate = _health_starving_rate
	health_regen_rate = _health_regen_rate
	forced_rest_time = _forced_rest_time
	stamina_regen_rate = stamina_regen_rate

	health = max_health
	food = max_food - 50 #DEBUG
	stamina = max_stamina
	food_value = health
	current_zone=_current_zone
	memory = {"zones": [current_zone], "edges": [], current_zone: current_zone._zone_value()}

func _process(delta: float) -> void:
	food -= delta * food_depletion_rate

	if food <= 0:
		health -= delta * health_starving_rate
	else:
		health += delta * health_regen_rate

	if stamina <= 0:
		if creature.check_is_on_floor():
			controller.queue_change_state(controller.fall_state, {"should grab": false})
		else:
			controller.queue_change_state(controller.stun_state, {"stun time": forced_rest_time})
		

func spawn(_type: CreatureType,_max_health: int, _max_stamina: int, _max_hunger: int, _attack_power: int, _current_zone: ZoneClass):
	type = _type
	max_health=_max_health
	health = _max_health
	max_stamina= _max_stamina
	stamina=_max_stamina
	max_food=_max_hunger
	food=_max_hunger
	attack_power=_attack_power
	current_zone=_current_zone
	memory = {"zones": [current_zone], "edges": [], current_zone: current_zone._zone_value()}

func _set_health(new_health):
	if (new_health<=0):
		Death.emit()
	if (new_health>=max_health):
		health = max_health
	else:
		health = new_health

func _set_stamina(new_stamina):
	if (new_stamina<=0):
		Death.emit()
	if (new_stamina>=max_stamina):
		stamina = max_stamina
	else:
		stamina = new_stamina

func _set_food(new_food):
	if (new_food<=0):
		Death.emit()
	if (new_food>=max_food):
		food = max_food
	else:
		food = new_food

func _update_memory(new_zone: ZoneClass, previous_zone: ZoneClass=null):
	if previous_zone == null:
		memory[new_zone] = new_zone._zone_value()
	else:
		memory["zones"].append(new_zone)
		memory["edges"].append([previous_zone, new_zone])
		memory["edges"].append([new_zone,previous_zone])
		memory[previous_zone] = previous_zone._zone_value()
		memory[new_zone] = new_zone._zone_value()

func _to_string():
	return "Type: " + CreatureType.keys()[type] + "\nHealth: " + str(health) + "\nStamina: " + str(stamina) + "\nHunger: " + str(food) + "\nmemory: " + str(memory)
