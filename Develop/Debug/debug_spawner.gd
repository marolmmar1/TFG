extends Node2D

@export var creature_scene: PackedScene
@export var berry_scene: PackedScene
@export var zone_props: Node2D

@onready var spawn_creature_button = $CanvasLayer/Control/Button
@onready var spawn_berry_button = $CanvasLayer/Control/Button2

var spawning = null

func _ready():
	spawn_creature_button.connect("pressed", func(): spawning = "creature")
	spawn_berry_button.connect("pressed", func(): spawning = "berry")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if spawning == "creature":
			spawn_creature()
		elif spawning == "berry":
			spawn_berry()
		spawning = null


func spawn_creature():
	var creature = creature_scene.instantiate()
	zone_props.add_child.call_deferred(creature)
	creature.global_position = get_global_mouse_position()

func spawn_berry():
	var berry = berry_scene.instantiate()
	zone_props.add_child.call_deferred(berry)
	berry.global_position = get_global_mouse_position()