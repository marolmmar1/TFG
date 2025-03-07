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

signal Death()

func spawn(_type: CreatureType,_max_health: int, _max_stamina: int, _max_hunger: int, _attack_power: int, _memory:Dictionary):
	type = _type
	max_health=_max_health
	health = _max_health
	max_stamina= _max_stamina
	stamina=_max_stamina
	max_food=_max_hunger
	food=_max_hunger
	attack_power=_attack_power
	memory=_memory

func _set_health(new_health):
	if (new_health<=0):
		Death.emit()
	if (new_health>=max_health):
		health = max_health
	else:
		health = new_health
