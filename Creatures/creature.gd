extends CharacterBody2D

class_name Creature

enum CreatureType{HERVIVORE, CARNIVORE, OMNIVORE}

var type: CreatureType
var max_health: int
var health: int
var max_stamina: int
var stamina: int
var max_hunger: int
var hunger: int
var attack_power: int
var memory: Dictionary

func spawn(_type: CreatureType,_max_health: int, _max_stamina: int, _max_hunger: int, _attack_power: int, _memory:Dictionary):
	type = _type
	max_health=_max_health
	health = _max_health
	max_stamina= _max_stamina
	stamina=_max_stamina
	max_hunger=_max_hunger
	hunger=_max_hunger
	attack_power=_attack_power
	memory=_memory

func _set_health(new_health):
	if (new_health<=0):
		queue_free()
	if (new_health>=max_health):
		health = max_health
	else:
		health = new_health
