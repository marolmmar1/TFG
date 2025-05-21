extends Area2D
class_name Door

signal on_creature_changes_zone(body: CharacterBody2D, exit: Door, enter: Door)

@export var other_side: Door
# Called when the node enters the scene tree for the first time.

func _on_body_entered(body):
	body = body as CharacterBody2D
	if body:
		on_creature_changes_zone.emit(body, self, other_side)
