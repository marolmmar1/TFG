extends Node

class_name Damageable

signal on_damage_taken(source, damage)

func take_damage(source, damage):
	on_damage_taken.emit(source, damage)