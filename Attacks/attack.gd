extends Area3D

enum AttackType {MELEE, RANGED}

@export_category("Main")
@export var damage: float
@export var attack_type: AttackType


func _on_body_entered(body: Node3D):
	if body is CharacterBody3D:
		var damageable = body.get_node("Damageable") as Damageable
		if damageable:
			damageable.on_damaged.emit()
