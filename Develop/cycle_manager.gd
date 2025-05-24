extends Node

var DAY_STAGES = ["Day", "Night"]

@export var stage_duration = [10000, 10000]

@onready var time_label = $"CanvasLayer/CycleCont/TimeLabel"
@onready var stage_label = $"CanvasLayer/CycleCont/StageLabel"

signal on_stage_entered(stage)
signal on_day_end()

var time = 0
var stage_index = 0

func _ready() -> void:
	await get_tree().process_frame
	on_stage_entered.emit(DAY_STAGES[stage_index])
	on_day_end.connect(reset_day)

func _process(delta: float) -> void:
	time += delta

	if time > stage_duration[stage_index]:
		change_stage()

	time_label.text = str(round(time * 100) / 100)
	stage_label.text = DAY_STAGES[stage_index]

func _on_debug_add_time_button_down() -> void:
	time += 1000

func _on_debug_add_time_2_button_down() -> void:
	change_stage()

func change_stage():
	stage_index = (stage_index + 1) % DAY_STAGES.size()
	time = 0

	if stage_index == 0:
		on_day_end.emit()

	on_stage_entered.emit(DAY_STAGES[stage_index])

func reset_day():
	for creature in get_tree().get_nodes_in_group("Creature"):
		creature.queue_free.call_deferred()
	for stat_bars in get_tree().get_nodes_in_group("StatBars"):
		stat_bars.queue_free.call_deferred()