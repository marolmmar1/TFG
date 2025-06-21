extends Node
class_name Markov

var estimated_zones = []
var average_route_length = 0
var path=[]

# Q-table: stores Q-values for (state, action) pairs
var q_table := {}
# Parameters
var alpha := 0.1	# Learning rate
var gamma := 0.9	# Discount factor
var epsilon := 0.2	# Exploration rate
var episodes := 100
var objective: ZoneClass

func _init():
	estimated_zones = []
	average_route_length = 0
	q_table = {}
	alpha = 0.1
	gamma = 0.9
	epsilon = 0.2
	episodes = 100
	objective = null

func reward_function(previous_zone: ZoneClass, next_zone: ZoneClass, creature: CreatureData = null) -> float:
	if creature != null:
		return get_test_reward(previous_zone, next_zone, creature)
	return get_heuristic(previous_zone, next_zone)

func get_heuristic(previous_zone: ZoneClass, next_zone: ZoneClass):
	return next_zone._zone_value() - previous_zone._zone_value()

func get_test_reward(previous_zone: ZoneClass, next_zone: ZoneClass, creature: CreatureData):
	var stationary= 0
	var visited = 0
	if path.size()>0:
		if path[path.size()-1] == next_zone:
			visited = 10
	if previous_zone == next_zone:
		stationary = 10
	
	return get_test_zone_value(next_zone, creature) - get_test_zone_value(previous_zone, creature) - stationary - visited

func get_test_zone_value(zone: ZoneClass, creature: CreatureData):
	return creature.memory[zone]["food_amount"] - creature.memory[zone]["threat_level"] - normalized_distance(zone,objective)

static func normalized_distance(a: ZoneClass, b: ZoneClass):
	var tilemap: TileMap = a.get_children()[0]
	var tilemap_distance = 1245.14
	var distance= abs(abs(a.get_global_position()) - abs(b.get_global_position()))
	return sqrt(distance.x*distance.x+distance.y*distance.y)/tilemap_distance

func get_connected_zones(zone: ZoneClass, creature: CreatureData) -> Array:
	var connections = []
	for edge in creature.memory["edges"]:
		if edge[0] == zone:
			connections.append(edge[1])
		elif edge[1] == zone:
			connections.append(edge[0])
	return connections


func choose_action(state: ZoneClass, test = false) -> ZoneClass:
	var possible_actions = [state]
	var connected_zones = state.get_connected_zones()
	if !(connected_zones.is_empty()):
		possible_actions += connected_zones
	if randf() < epsilon:
		# Explore
		return possible_actions[randi() % possible_actions.size()]
	# Exploit
	var best_action = possible_actions[0]
	var best_q = q_table.get([state, best_action], 0.0)
	for action in possible_actions:
		var q = q_table.get([state, action], 0.0)
		if q > best_q:
			best_q = q
			best_action = action
	return best_action

func run_test_q_learning(creature: CreatureData):	
	average_route_length = 0
	for i in range(episodes):
		var state = creature.current_zone
		path=[state]
		while state != objective:
			var action = choose_action(state)
			path.append(action)
			var next_state = action
			var reward = reward_function(state, next_state, creature)
			var current_q = q_table.get([state, action], 0.0)
			var max_future_q = 0.0
			for next_action in next_state.get_connected_zones() + [next_state]:
				var q = q_table.get([next_state, next_action], 0.0)
				if q > max_future_q:
					max_future_q = q
			var new_q = current_q + alpha * (reward + gamma * max_future_q - current_q)
			q_table[[state, action]] = new_q
			state = next_state
		average_route_length = average_route_length + path.size()
	average_route_length = average_route_length/episodes
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
