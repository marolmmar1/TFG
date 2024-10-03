extends ProgressBar

@onready var damage_bar = $DamageBar


var health = 0 : set = _set_health
var recoverable_health = 0 : set = _set_recoverable_health

func _set_health(new_health):
	health = min(max_value, new_health)
	value = health

func _set_recoverable_health(new_health):
	recoverable_health = min(max_value, new_health)
	damage_bar.value = recoverable_health

func init_health(_health):
	health = _health
	recoverable_health = health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
