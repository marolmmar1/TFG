extends Node

var data: CreatureData 
var stop = true
var high_level_state_manager:HighLevelStateManager

# Called when the node enters the scene tree for the first time.


func _greedy(state: HighLevelState)->LeaveAction:
	
	if state.current_zone.food_amount==1 and state.food==1:
		return _greedy_leave_or_explore(state)
	elif state.current_zone.threat_level>2 and state.health==1:
		return _greedy_leave_or_explore(state)
	elif state.current_zone._get_zone_value() >= 2 and state.health>=2 and state.stamina>=1 and state.food>=1:
		return null
	else:
		return _greedy_leave_or_explore(state)

#Returns best zone to go or zone to explore
func _greedy_leave_or_explore(state: HighLevelState, debug=false)->LeaveAction:
	if randi_range(1,4) == 4 or state.zones.size()==0:
		return explore(state)
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
			if debug:
				print("leave to " + str(best_zone.id.name))
			var astar = HLAStar.new()
			var next_zone = astar.a_star(data.memory, data.current_zone, best_zone.id)[1]
			var leave = LeaveAction.new()
			leave.choose_target(data.current_zone, next_zone)
			return leave
		else:
			return explore(state)

func explore(state: HighLevelState, debug = false)->LeaveAction:
	if debug:
		print("exploring")
	var leave = LeaveAction.new()
	var tries = 3
	while tries > 0:
		tries = tries -1
		var door = randi_range(0, state.current_zone.id.doors.size()-1)
		if debug:
			print("considering"+ str(state.current_zone.id.doors[door].name))
		for zone in state.zones:
			if not(zone.id == state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent()):
				if debug:
					print("exploring to " + str(zone.id.name))
				leave.choose_target(state.current_zone.id, zone.id)
				return leave
		if tries == 0:
			if debug:
				print("leave to " + str(state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent().name))
			leave.choose_target(state.current_zone.id, state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent())
			return leave
	return null