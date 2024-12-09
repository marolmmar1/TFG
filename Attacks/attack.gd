extends Area3D

enum AttackType {MELEE, RANGED}

@export_category("Provided")
@export var weapon_source: Weapon

@export_category("Main")
@export var lifetime := 0.1

var source_pos: Vector3

func init() -> void:
	if not source_pos:
		source_pos = global_position
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D:
		var damageable = body.get_node("Damageable") as Damageable
		if damageable:
			damageable.get_damaged(source_pos, weapon_source)
			self.process_mode = Node.PROCESS_MODE_DISABLED
			visible = false
