extends Node
class_name Weapon

@export_category("Main")
@export var attack: PackedScene
@export var weapon_type: WeaponType
@export var weapon_anim_type: WeaponAnimType
@export var max_combo_count := 3

enum WeaponType {MELEE, RANGED}
enum WeaponAnimType {SWEEP, STAB} #TODO add more

func perform_primary(player):
	var attack_instance = attack.instantiate()
	player.add_child(attack_instance)
	attack_instance.global_transform = player.global_transform

# func perform_secondary(player):
# 	var attack_instance = attack.instantiate()
# 	player.add_child(attack_instance)
# 	attack_instance.global_transform = player.global_transformfunc
