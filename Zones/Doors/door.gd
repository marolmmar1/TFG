extends Area2D

class_name Door

@export var other_side: Door
# Called when the node enters the scene tree for the first time.

func _on_body_entered(body: CharacterBody2D):
	print("body entered")

