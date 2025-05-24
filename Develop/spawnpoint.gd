extends Node2D

@export var creature_scene: PackedScene
@export var stat_bars_scene: PackedScene

#HACK
@onready var zone_props = get_parent().get_parent().find_child("ZoneProps")
@onready var cycle_manager = get_parent().get_parent().get_parent().find_child("CycleManager")
@onready var UI = get_parent().get_parent().get_parent().get_parent().find_child("UI")

func _ready():
	cycle_manager.on_stage_entered.connect(spawn_by_stage)

func spawn_by_stage(stage):
	var creature = creature_scene.instantiate()
	var stat_bars = stat_bars_scene.instantiate()

	stat_bars.character = creature

	zone_props.add_child.call_deferred(creature)
	UI.add_child.call_deferred(stat_bars)

	await get_tree().process_frame
	creature.global_position = global_position
