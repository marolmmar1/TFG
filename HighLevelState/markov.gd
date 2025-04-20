extends Node
class_name Markov
var estimated_zones = []

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
