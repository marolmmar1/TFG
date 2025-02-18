extends Creature

@onready var healthbar = $healthbar

func _ready():
    spawn(Creature.CreatureType.HERVIVORE, 10,10,10,2, {})
    healthbar._init_health(10)
    print(health, stamina, hunger)

func mod(_new_health):
    _set_health(_new_health)
    healthbar._set_health(_new_health)
