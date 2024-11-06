@tool

extends AnimationPlayer

@export var weapon_blend: float = 0.0:
	set(value):
		if not anim_length:
			_ready()
		weapon_blend = value
		weapon_anim_tree["parameters/TimeSeek/seek_request"] = value * anim_length

@export var weapon: Node3D
@export var weapon_main_anim: String

var weapon_anim_tree: AnimationTree
var anim_length: float

func _ready() -> void:
	weapon_anim_tree = weapon.get_node("AnimationTree")
	anim_length = weapon_anim_tree.get_animation(weapon_main_anim).length
