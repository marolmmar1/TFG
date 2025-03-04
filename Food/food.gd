extends Node2D

signal food_eaten(food: Node2D)

func _on_body_entered(body: CharacterBody2D):
	food_eaten.emit(self)