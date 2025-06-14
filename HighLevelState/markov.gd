extends Node
class_name Markov

var estimated_zones = []

# Q-table: stores Q-values for (state, action) pairs
var q_table := {}
# Parameters
var alpha := 0.1	# Learning rate
var gamma := 0.9	# Discount factor
var epsilon := 0.2	# Exploration rate
var episodes := 100

func get_connected_zones(zone: ZoneClass, creature: CreatureData) -> Array:
	var connections = []
	for edge in creature.memory["edges"]:
		if edge[0] == zone:
			connections.append(edge[1])
		elif edge[1] == zone:
			connections.append(edge[0])
	return connections

func get_heuristic(zone: ZoneClass, creature: CreatureData):
	if creature.memory.has(zone):
		#var value =(creature.memory[zone]["threat_level"] + creature.memory[zone]["food_amount"])/2.0
		var value = creature.health/creature.memory[zone]["threat_level"] + creature.memory[zone]["food_amount"]/creature.food
		return roundf(value)
	return 0

func choose_action(state: ZoneClass, creature: CreatureData) -> ZoneClass:
	var actions = get_connected_zones(state, creature)
	actions.append(state) # Include option to stay
	
	if randf() < epsilon:
		# Explore
		return actions[randi() % actions.size()]
	
	# Exploit
	var best_action = actions[0]
	var best_q = q_table.get([state, best_action], 0.0)
	for action in actions:
		var q = q_table.get([state, action], 0.0)
		if q > best_q:
			best_q = q
			best_action = action
	return best_action

func get_best_heuristic_zone(creature: CreatureData) -> ZoneClass:
	var best_zone = creature.memory["zones"][0]
	var best_heuristic = get_heuristic(best_zone, creature)
	for zone in creature.memory["zones"]:
		var h = get_heuristic(zone, creature)
		if h > best_heuristic:
			best_heuristic = h
			best_zone = zone
	return best_zone


func reward_function(zone: ZoneClass, creature: CreatureData) -> float:
	return get_heuristic(zone, creature)

func run_q_learning(creature: CreatureData):
	var path=[]
	for i in range(episodes):
		path=[]
		var state = creature.current_zone
		while true:
			var action = choose_action(state, creature)
			var reward = reward_function(action, creature)
			var next_state = action
			
			var current_q = q_table.get([state, action], 0.0)
			
			var max_future_q = 0.0
			for next_action in get_connected_zones(next_state,creature) + [next_state]:
				var q = q_table.get([next_state, next_action], 0.0)
				if q > max_future_q:
					max_future_q = q
			
			var new_q = current_q + alpha * (reward + gamma * max_future_q - current_q)
			q_table[[state, action]] = new_q
			path.append(state)
			if action == get_best_heuristic_zone(creature):
				break
			state = next_state
	return path

func print_q_table():
	var res = "{"
	for key in q_table.keys():
		var row = ""
		if res != "{":
			row = ", [" + key[0].name + ", " + key[1].name + "] = " + str(q_table[key])
		else:
			row = "[" + key[0].name + ", " + key[1].name + "] = " + str(q_table[key])
		res += row
	res += "}"
	print(res)

func get_best_path(creature: CreatureData):
	var current_zone = creature.current_zone
	var garph = {"zones": creature.memory["zones"], "edges": creature.memory["edges"]}
	var astar = HLAStar.new()
	print(current_zone.name, get_best_heuristic_zone(creature).name)
	var path = astar.a_star(garph, current_zone, get_best_heuristic_zone(creature), self)
	return path

# if not in memory,adds zones adjacent to current zone and expects a medium threat level and food ammount
func compose_matix(creature: CreatureData, debug =false):
	var actions = []
	for door: Door in creature.current_zone.doors:
					var other_side : ZoneClass = door.other_side.get_parent().get_parent().get_parent()
					if not creature.memory.keys().has(other_side):
						estimated_zones.append(other_side)
						creature._update_memory(other_side)
						creature.memory["zones"].append(other_side)
						creature.memory["edges"].append([creature.current_zone, other_side])
						creature.memory["edges"].append([other_side, creature.current_zone])
						creature.memory[other_side]["threat_level"] = 2
						creature.memory[other_side]["food_amount"] = 2
	for origin in creature.memory["zones"]:
		for destination in creature.memory["zones"]:				
			actions.append({"origin": origin, "destination": destination})
	if debug:
		print(action_value(creature, actions[1]))
	return actions


func build_weight_matrix(states: Array, edges: Array) -> Array:
	var n = states.size()
	var matrix = []
	var weight = 1.00/(3**4)
	var adjacency = {}
	for edge in edges:
		var a = edge[0]
		var b = edge[1]
		if !adjacency.has(a):
			adjacency[a] = []
		if !adjacency.has(b):
			adjacency[b] = []
		adjacency[a].append(b)
		adjacency[b].append(a)

	for i in range(n):
		matrix.append([])
		var id_i = states[i].current_zone.id
		for j in range(n):
			var id_j = states[j].current_zone.id
			if id_i == id_j or (adjacency.has(id_i) and id_j in adjacency[id_i]):
				matrix[i].append(weight)
			else:
				matrix[i].append(0.0)
	
	return matrix

func quantize_creature_state(value, max_value)->int:
	var quantized_value = 1
	var threshold = max_value/3
	if value > 2*threshold:
		quantized_value = 3
	elif value > threshold:
		quantized_value = 2
	return quantized_value

func action_value(creature: CreatureData, action: Dictionary):
	var astar = HLAStar.new()
	var path = astar.a_star(creature.memory, action.origin, action.destination)
	print(path)
	var value = (quantize_creature_state(creature.health, creature.max_health)
					+ quantize_creature_state(creature.stamina, creature.max_stamina)
					+ quantize_creature_state(creature.food, creature.max_food))/3
	for zone in path:
		value -= creature.memory[zone]["threat_level"]
	return value

func restore_memory(creature: CreatureData, zones: Array):
	for zone in zones:
		if creature.memory.keys().has(zone):
			creature.memory.erase(zone)
			creature.memory["zones"].erase(zone)
			for edge in creature.memory["edges"]:
				if edge[0] == zone or edge[1] == zone:
					creature.memory["edges"].erase(edge)
	estimated_zones = []
