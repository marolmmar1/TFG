extends Area3D

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D:
		var damageable = body.get_node("Damageable") as Damageable
		if damageable:
			damageable.on_damaged.emit()
