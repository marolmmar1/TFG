extends Node

signal on_audio_player_enter(audio_player)

@export var audio_minimum_offset: float = 0.35

var free_audio_stream_players: Array[AudioStreamPlayer] = []
var used_audio_stream_players: Array[AudioStreamPlayer] = []

func add_audio_player(audio_player: AudioPlayer) -> void:
	if audio_player.on_play_audio:
		audio_player.on_play_audio.connect(play_audio)

func play_audio(stream: AudioStream, volume_offset: float, bus: String) -> void:

	# --- Restrictions ---

	if used_audio_stream_players.filter(
			func(x): return x.stream == stream && x.stream.get_length() - x.get_child(0).time_left < audio_minimum_offset
		).size() > 0:
		return

	# --- Play Audio ---

	var stream_player = free_audio_stream_players.pop_front()

	if not stream_player:
		stream_player = AudioStreamPlayer.new()
		add_child(stream_player)
		stream_player.add_child(Timer.new())
		stream_player.finished.connect(free_stream_player.bind(stream_player))

	used_audio_stream_players.append(stream_player)

	stream_player.stream = stream
	stream_player.volume_db = volume_offset
	stream_player.bus = bus
	stream_player.get_child(0).wait_time = stream.get_length()

	stream_player.play()
	stream_player.get_child(0).start()

func free_stream_player(stream_player: AudioStreamPlayer) -> void:
	used_audio_stream_players.erase(stream_player)
	free_audio_stream_players.append(stream_player)
	stream_player.stream = null
	stream_player.get_child(0).stop()
