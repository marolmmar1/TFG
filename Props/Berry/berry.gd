extends Node2D

@export var food_value: float = 25.0

func deplete():
	queue_free()