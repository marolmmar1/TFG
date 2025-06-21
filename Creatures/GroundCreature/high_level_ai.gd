extends Node

@onready var data: CreatureData = get_parent().get_parent().get_children()[6]
var stop = true
@onready var basic_agent = HLAStar.new()
@onready var advanced_agent = Markov.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	print(advanced_agent.print_q_table())

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
	var debugData = create_dummy(high_level_state_manager)
	var objective = select_objective_zone(debugData, high_level_state_manager)
	advanced_agent.objective = objective.id
	var results = compose_file_structure(debugData)
	stress_test_markov(high_level_state_manager, debugData,results["id"][0])
	"""
	var qLearning_results = test_QLearning(debugData, results)
	results = qLearning_results["results"]
	var astarresults = test_astar(debugData, results, objective)
	results = astarresults["results"]
	results["route heuristic"][0] = path_effort(qLearning_results["path"], debugData)
	results["route heuristic"][1] = path_effort(astarresults["path"], debugData)
	write_or_append_csv("debug.csv", results)"""
	
func test_QLearning(debugData: CreatureData, results , stress = false):
	if stress:
		return null
	else:
		#var markov_config = stress_test_markov(high_level_state_manager, debugData, best_zone,id)
		#markov.alpha = markov_config[0]
		results["alpha"][0] = advanced_agent.alpha
		#markov.gamma = markov_config[1]
		results["gamma"][0] = advanced_agent.gamma
		#markov.epsilon = markov_config[2]
		results["epsilon"][0] = advanced_agent.epsilon
		#markov.episodes = markov_config[3]
		results["episodes"][0] = advanced_agent.episodes
		var start_time := Time.get_ticks_usec()
		var mpath =advanced_agent.run_test_q_learning(debugData)
		var end_time := Time.get_ticks_usec()
		var elapsed_usec := end_time - start_time
		results["time"][0] = float(elapsed_usec) / 1_000_000.0
		results["route length"][0] = mpath.size()
		return {"results": results, "path": mpath}

func test_astar(debugData: CreatureData, results, objective):
	var start_time := Time.get_ticks_usec()
	var next_zone =  basic_agent.a_star(debugData.memory, debugData.current_zone, objective.id)
	var end_time := Time.get_ticks_usec()
	var elapsed_usec := end_time - start_time
	results["time"][0] = float(elapsed_usec) / 1_000_000.0
	results["route length"][0] = next_zone.size()
	return {"results": results, "path": next_zone}

func create_dummy(high_level_state_manager: HighLevelStateManager) -> CreatureData:
	var debugData = CreatureData.new()
	debugData.init(null, null, 0, 0, 0,0,0, 100, 100, 100,1, data.current_zone)
	
	var zone_graph = get_parent().get_parent().get_parent().get_parent().get_parent().zone_graph
	debugData.memory["zones"] = zone_graph.get("zones")
	debugData.memory["edges"] = zone_graph.get("edges")
	debugData.memory = randomize_memory(debugData)
	return debugData

func randomize_memory(debugData:CreatureData):
	for zone in debugData.memory["zones"]:
		debugData.memory[zone] = {"threat_level": randi_range(1,3), "food_amount": randi_range(1,3)}
	debugData.memory[data.current_zone] = {"threat_level": 1, "food_amount": 1}
	return debugData.memory


func stress_test_markov(high_level_state_manager, debugData,id):
	var results = {
		"id": [],
		"algorithm":[],
		"time":[],
		"graph_size":[debugData.memory["zones"].size(),debugData.memory["zones"].size()],
		"route heuristic": [],
		"route length": [],
		"avg route length": [],
		"alpha":[],
		"gamma":[],
		"epsilon":[],
		"episodes":[]
		}
	var best_config = []
	var max = 0
	debugData.memory = randomize_memory(debugData)
	var objective = select_objective_zone(debugData, high_level_state_manager).id
	advanced_agent.objective = objective
	for i in range(1):
		results["id"].append(id)
		results["algorithm"].append("Q-learning")
		#var markov_config = [.1,randf_range(0,1),.2,100]
		var markov_config = [.1,.9,.2,10]
		advanced_agent.alpha = markov_config[0]
		results["alpha"].append(advanced_agent.alpha)
		advanced_agent.gamma = markov_config[1]
		results["gamma"].append(advanced_agent.gamma)
		advanced_agent.epsilon = markov_config[2]
		results["epsilon"].append(advanced_agent.epsilon)
		advanced_agent.episodes = markov_config[3]
		results["episodes"].append(advanced_agent.episodes)
		var start_time := Time.get_ticks_usec()
		var mpath = advanced_agent.run_test_q_learning(debugData)
		"""print("from " + str(debugData.current_zone.name) + " to " + str(objective.name))
		print("--------------------")
		for zone in mpath:
			print(zone.name	)"""
		"""var end_time := Time.get_ticks_usec()
		var elapsed_usec := end_time - start_time
		results["time"].append(float(elapsed_usec) / 1_000_000.0)
		var effort =path_effort(mpath, debugData)
		results["route length"].append(mpath.size())
		results["avg route length"].append(advanced_agent.average_route_length)
		if effort > max:
			best_config = markov_config
		results["route heuristic"].append(effort)
	write_or_append_QLearning_csv("advanced_agent-baseline.csv", results)"""
	return best_config

func select_objective_zone(debugData: CreatureData, high_level_state_manager : HighLevelStateManager):
	var best_zone
	var state = high_level_state_manager.get_state(debugData)
	var max = 1
	var distance=100
	for zone in state.zones:
		if zone.distance==null:
			distance=zone.distance
			best_zone=zone
		if zone._get_zone_value() >= max and zone.distance<=distance:
			max = zone._get_zone_value()
			distance=zone.distance
			best_zone=zone
	return best_zone

func compose_file_structure(debugData:CreatureData):
	var id = ""
	for value in Time.get_datetime_dict_from_system().values():
		if id == "":
			id += str(value)
		if !(value is bool):
			id += "-" + str(value)
	id += "-" + str(Time.get_ticks_usec())
	var results = {
		"id": [id,id],
		"algorithm":["Q-learning","A*"],
		"time":[0.0,0.0],
		"graph_size":[debugData.memory["zones"].size(),debugData.memory["zones"].size()],
		"route length":[0,0],
		"route heuristic": [0,0],
		"alpha":[0,0],
		"gamma":[0,0],
		"epsilon":[0,0],
		"episodes":[0,0]
		}
	return results

func path_effort(path, creature: CreatureData):
	var goal = 0
	if path.size()>0:
		goal = path[path.size()-1].food_amount
	var effort = data.stamina/path.size()
	var risk = 0
	for zone in path:
		risk += zone.threat_level
	return goal + effort - risk

func exportData(results):
	print(results.keys().reduce(func(a, b): return str(a) + "; " + str(b)))

func write_or_append_csv(path: String, results) -> void:
	path = "user://" + path
	var file_exists := FileAccess.file_exists(path)
	var file := FileAccess.open(path, FileAccess.READ_WRITE if file_exists else FileAccess.WRITE)
	if not file:
		return

	if file_exists:
		# Move to the end of the file to append data
		file.seek_end()
	else:
		# If file is new, write a header first
		file.store_line(results.keys().reduce(func(a, b): return str(a) + ", " + str(b)))

	for i in [0,1]:
		var storeData=[]
		for key in results.keys():
			storeData.append(results[key][i])
		var formatted ="%s,%s,%.4f,%d,%d,%.4f,%.4f,%.4f,%.4f,%d" % storeData
		file.store_line(formatted)
	file.close()

func write_or_append_QLearning_csv(path: String, results) -> void:
	path = "user://" + path
	var file_exists := FileAccess.file_exists(path)
	var file := FileAccess.open(path, FileAccess.READ_WRITE if file_exists else FileAccess.WRITE)
	if not file:
		return

	if file_exists:
		# Move to the end of the file to append data
		file.seek_end()
	else:
		# If file is new, write a header first
		file.store_line(results.keys().reduce(func(a, b): return str(a) + ", " + str(b)))

	for i in [0,1]:
		var storeData=[]
		for key in results.keys():
			storeData.append(results[key][i])
		var formatted ="%s,%s,%.4f,%d,%.4f,%d,%.4f,%.4f,%.4f,%.4f,%d" % storeData
		file.store_line(formatted)
	file.close()
