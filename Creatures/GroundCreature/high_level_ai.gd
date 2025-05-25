extends Node

@onready var data: CreatureData = get_parent().get_parent().get_children()[6]
var stop = true


# Called when the node enters the scene tree for the first time.


func _greedy(state: HighLevelState, debug = false)->LeaveAction:
	if state.current_zone._get_zone_value() >= 2 and state.health>=2 and state.stamina>=1 and state.food>=1:
		return null
	else:
		if debug:
			debug_algorithms()
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
			var next_zone =  astar.a_star(data.memory, data.current_zone, best_zone.id)[1]
			print("greedy")
			if(randi_range(1,2)==1):
				next_zone= astar.a_star(data.memory, data.current_zone, best_zone.id)[1]
			else:
				markov()
			var leave = LeaveAction.new()
			leave.choose_target(data.current_zone, next_zone)
			return leave
		else:
			return explore(state,true)

func explore(state: HighLevelState, debug = false)->LeaveAction:
	if debug:
		print("exploring")
	var leave = LeaveAction.new()
	var tries = 3
	while tries > 0:
		tries = tries -1
		var door = randi_range(0, state.current_zone.id.doors.size()-1)
		if debug:
			print("considering "+ str(state.current_zone.id.doors[door].name))
		for zone in state.zones:
			if not(zone.id == state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent()):
				if debug:
					print("exploring to " + str(zone.id.name))
				leave.choose_target(state.current_zone.id, zone.id)
				return leave
		if tries == 0:
			if debug and state.current_zone.id.doors[door].other_side:
				print("leave to " + str(state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent().name))
			if state.current_zone.id.doors[door].other_side:
				leave.choose_target(state.current_zone.id, state.current_zone.id.doors[door].other_side.get_parent().get_parent().get_parent())
				return leave
	return null

func markov():
	var markov = Markov.new()
	markov.run_q_learning(data)
	print("qtable: ", markov.q_table.keys().size())
	markov.print_q_table()


func debug_algorithms():
	var high_level_state_manager = HighLevelStateManager.new()
	var debugData = CreatureData.new()
	debugData.init(null, null, 0, 0, 0,0,0, 100, 100, 100,1, data.current_zone)
	
	var zone_graph = get_parent().get_parent().get_parent().get_parent().get_parent().zone_graph
	debugData.memory["zones"] = zone_graph.get("zones")
	debugData.memory["edges"] = zone_graph.get("edges")
	for zone in debugData.memory["zones"]:
		debugData.memory[zone] = {"threat_level": zone.threat_level, "food_amount": zone.food_amount}
	debugData.memory[data.current_zone] = {"threat_level": 1, "food_amount": 1}
	var max = 1
	var distance=100
	var best_zone
	var state = high_level_state_manager.get_state(debugData)
	for zone in state.zones:
		if zone.distance==null:
			distance=zone.distance
			best_zone=zone
		if zone._get_zone_value() >= max and zone.distance<=distance:
			max = zone._get_zone_value()
			distance=zone.distance
			best_zone=zone
	var results = {"algorithm":["Q-learning","A*"],
		"time":[0.0,0.0],
		"graph_size":[debugData.memory["zones"].size(),debugData.memory["zones"].size()],
		"route heuristic": [0,0],
		"alpha":[0,0],
		"gamma":[0,0],
		"epsilon":[0,0],
		"episodes":[0,0]
		}
	var markov = Markov.new()
	var start_time := Time.get_ticks_usec()
	markov.run_q_learning(debugData)
	var markov_config = [randf(),randf(),randf(),randi_range(0,1000)]
	markov.alpha = markov_config[0]
	results["alpha"][0] = markov.alpha
	markov.gamma = markov_config[1]
	results["gamma"][0] = markov.gamma
	markov.epsilon = markov_config[2]
	results["epsilon"][0] = markov.epsilon
	markov.episodes = markov_config[3]
	results["episodes"][0] = markov.episodes
	var end_time := Time.get_ticks_usec()
	var elapsed_usec := end_time - start_time
	results["time"][0] = float(elapsed_usec) / 1_000_000.0
	start_time = Time.get_ticks_usec()
	var astar = HLAStar.new()
	start_time = Time.get_ticks_usec()
	var next_zone =  astar.a_star(debugData.memory, debugData.current_zone, best_zone.id)
	end_time = Time.get_ticks_usec()
	elapsed_usec = end_time - start_time
	results["time"][1] = float(elapsed_usec) / 1_000_000.0
	var mpath = markov.get_best_path(debugData)
	results["route heuristic"][0] = path_effort(mpath, debugData)
	results["route heuristic"][1] = path_effort(next_zone, debugData)
	write_or_append_csv("debug.csv", results)
	

func path_effort(path, creature: CreatureData):
	var goal = path[path.size()-1].food_amount
	var effort = data.stamina/path.size()
	var risk = 0
	for zone in path:
		risk += zone.threat_level
	risk = creature.health/risk
	return goal + effort + risk

func exportData(results):
	print(results.keys().reduce(func(a, b): return str(a) + ", " + str(b)))


func write_or_append_csv(path: String, results) -> void:
	path = "user://" + path
	var file_exists := FileAccess.file_exists(path)
	var file := FileAccess.open(path, FileAccess.READ_WRITE if file_exists else FileAccess.WRITE)
	if not file:
		print("Error: Could not open file at ", path)
		return

	if file_exists:
		# Move to the end of the file to append data
		print("file exists")
		file.seek_end()
	else:
		# If file is new, write a header first
		print(results.keys().reduce(func(a, b): return str(a) + ", " + str(b)))
		file.store_line(results.keys().reduce(func(a, b): return str(a) + ", " + str(b)))

	for i in [0,1]:
		var storeData=[]
		for key in results.keys():
			storeData.append(results[key][i])
		file.store_line("%s,%.4f,%d,%.4f,%.4f,%.4f,%.4f,%d" % storeData)
	file.close()
