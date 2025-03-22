extends Node

var data: CreatureData 
var stop = true
var high_level_state_manager:HighLevelStateManager

# Called when the node enters the scene tree for the first time.

func _greedy(state: HighLevelState):
	if state.current_zone._get_zone_value() >= 2 and state.health>=2 and state.stamina>=1 and state.food>=1:
		print("stay")
	elif state.current_zone.food_amount==1 and state.food==1:
		_greedy_leave_or_explore(state)
	elif state.current_zone.threat_level>2 and state.health==1:
		_greedy_leave_or_explore(state)
	else:
		_greedy_leave_or_explore(state)

func _greedy_leave_or_explore(state: HighLevelState):
	if randi_range(1,4) == 4 or state.zones.size()==0:
		explore(state)
	else:
		var max = 1
		var distance
		var best_zone
		for zone in state.zones:
			if zone.distance==null:
				distance=zone.distance
				best_zone=zone
			if zone._get_zone_value() >= max and zone.distance<=distance:
				max = zone._get_zone_value()
				distance=zone.distance
				best_zone=zone
		if best_zone._get_zone_value() >= 2:
			print("leave to " + str(best_zone.id.name))
		else:
			explore(state)

func explore(state: HighLevelState):
	print("exploring")
	var tries = 3
	while tries > 0:
		tries = tries -1
		var door = randi_range(0, state.current_zone.id.doors.size()-1)
		print("considering"+ str(state.current_zone.id.doors[door].name))
		for zone in state.zones:
			if not(zone.id == state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent()):
				print("exploring to " + str(zone.id.name))
				break
		if tries == 0:
			print("leave to " + str(state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent().name))