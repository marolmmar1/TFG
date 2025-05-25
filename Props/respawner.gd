extends Node2D

@onready var berry := preload("res://Props/Berry/Berry.tscn")
@onready var props = get_parent().get_parent().find_child("ZoneProps")




func spawn():
	var berry_instance = berry.instantiate()
	props.add_child(berry_instance)
	berry_instance.global_position = global_position