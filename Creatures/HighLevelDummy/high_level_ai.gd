extends Node

var data: CreatureData 
var stop = true
# Called when the node enters the scene tree for the first time.
func _ready():
	data = get_parent().get_parent().get_child(1)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stop && not data.current_zone==null:
		stop = false
		_leave_zone(data.current_zone.doors[0].other_side)

func _leave_zone(door: Door):
	var new_zone = door.get_parent().get_parent().get_parent()
	var dummy =  get_parent().get_parent()
	data.current_zone.remove_child(dummy)
	data.current_zone.visible = false
	new_zone.creatures.add_child(dummy)
	dummy.global_position = door.get_node("ExitSpawn").global_position
	new_zone.visible = true
	data._update_memory(new_zone, data.current_zone)
	print(data.memory)