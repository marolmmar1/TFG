extends Camera3D

@export_category("Provided")

@export var player: Node3D

var camera_target: Vector3


@export_category("Main")

@export var speed : float = 5.0

@export var max_camera_offset : float = 1.35

@export var offset_from_player : Vector3

#FIXME move all this to a child, probably	

var debug_draw = null

func _ready() -> void:
	#DEBUG
	debug_draw = Draw3D.new()
	get_tree().root.get_child(0).add_child(debug_draw)


func _process(delta):
	camera_target = player.global_position + offset_from_player

	if camera_target:
		if player.locked_on_target:
			var camera_offset = player.locked_on_target.global_position * Vector3(1, 0, 1) - camera_target
			camera_offset = camera_offset.normalized() * clamp(camera_offset.length(), 0, max_camera_offset)
			position = lerp(position, camera_target + camera_offset * Vector3(1, 0, 1), delta * speed)
		else:
			position = lerp(position, camera_target, delta * speed)

	#DEBUG
	debug_draw.clear()
	if player:
		debug_draw.draw_line([player.global_position, self.global_position - Vector3(0, 0.1, 0)], Color.GREEN)
	if player.locked_on_target:
		debug_draw.draw_line([player.locked_on_target.global_position, self.global_position - Vector3(0, 0.1, 0)], Color.BLUE)
