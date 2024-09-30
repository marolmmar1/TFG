class_name EnemyController
extends CharacterBody3D

func _ready():
	self.add_to_group("Targetables")
	EventSystem.main_game_bus.on_enemy_enter.emit(self)

	var damageable = get_node("Damageable") as Damageable
	damageable.on_damaged.connect(take_damage)
	
func take_damage():
	pass
	