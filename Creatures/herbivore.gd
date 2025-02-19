extends Creature
	
func _ready():
	spawn(Creature.CreatureType.HERVIVORE, 10,10,10,2, {})
	print(health, stamina, hunger)

func mod(_new_health):
	_set_health(_new_health)