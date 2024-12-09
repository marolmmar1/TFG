extends Node
class_name Weapon

@export_category("Main")
@export var attack_instance_points: Array[Vector4] #pos and size
@export var attack: PackedScene
@export var weapon_type: WeaponType
@export var weapon_anim_type: WeaponAnimType
@export var max_combo_count := 3
@export var knockback := 10.0

@export_category("Provided")
@export var player: CharacterBody3D

enum WeaponType {MELEE, RANGED}
enum WeaponAnimType {SWEEP, STAB} #TODO add more

func perform_primary():
	#not sure if this is the best way to create the hitbox of the attack
	for i in attack_instance_points.size():
		var attack_instance = attack.instantiate()
		attack_instance.weapon_source = self
		attack_instance.source_pos = player.global_position
		player.add_child(attack_instance)
		attack_instance.global_transform = player.global_transform
		attack_instance.position = Vector3(attack_instance_points[i][0], attack_instance_points[i][1] - 1.0, attack_instance_points[i][2])
		attack_instance.scale = Vector3(attack_instance_points[i][3], attack_instance_points[i][3], attack_instance_points[i][3])
		
# func perform_secondary(player):
# 	var attack_instance = attack.instantiate()
# 	player.add_child(attack_instance)
# 	attack_instance.global_transform = player.global_transformfunc
