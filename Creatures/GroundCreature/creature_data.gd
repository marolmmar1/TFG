extends Node

class_name CreatureData

enum CreatureType{HERVIVORE, CARNIVORE, OMNIVORE}

var type: CreatureType
var max_health: float = 100
var health: float
var max_food: float = 100
var food: float
var max_stamina: float = 100
var stamina: float
var attack_power: float
var memory: Dictionary
var current_zone: ZoneClass

signal Death()

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
	memory = {"zones": [current_zone], "edges": []}
	memory[current_zone]= current_zone._zone_value()

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