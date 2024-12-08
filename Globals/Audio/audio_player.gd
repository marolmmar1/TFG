extends Node

class_name AudioPlayer

signal on_play_audio(stream: AudioStream, volume_offset: float, bus: String)

@export var stream : AudioStream
@export var volume_offset : float = 0.0
@export var bus : String = "Master"

func play_audio() -> void:
	on_play_audio.emit(stream, volume_offset, bus)

func _ready() -> void:
	if AudioSystem:
		AudioSystem.on_audio_player_enter.emit(self)
	else:
		#HACK probably unnecessary
		get_tree().create_timer(0.5).timeout.connect(func(): AudioSystem.on_audio_player_enter.emit(self))
	