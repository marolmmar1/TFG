extends Node

@onready var camera: Camera3D = self.get_parent()

var duration := 0.0
var amount := 0.0

func _ready() -> void:
	EventSystem.main_game_bus.on_camera_shake.connect(camera_shake)

func camera_shake(_amount: float, _duration: float) -> void:		
	
	#TODO modify intensity by settings
	var intensity := 1000.0
	if _amount > intensity:
		amount = intensity
	else:
		amount = _amount

	duration = _duration

func _process(delta: float) -> void:
	if duration <= 0:
		camera.h_offset = 0
		camera.v_offset = 0
		return
	
	duration -= delta

	camera.h_offset = randf() * amount
	camera.v_offset = randf() * amount