extends Node2D

@export var healt_n: int = 3
@export var food_n: int = 3
@export var stamina_n: int = 3
@export var dist_n: int = 4
@export var max_considerable_distance: float = 2500
@export var max_considerable_attack_power: float = 100
@export var max_considerable_food_value: float = 100
@export var food_value_n: int = 4
@export var threat_level_n: int = 4
@export var astar_threshold: int = 3

#DEBUG
@export var debug := false

var zone_props

var item_node = {}
var creatures = []

func init(_zone):
	zone_props = _zone.zone_props


func get_state(creature) -> LowLevelState:
	if not zone_props:
		return

	var health = remap_and_quantize_value(creature.data.health, 0, creature.data.max_health, 0, healt_n)
	var food = remap_and_quantize_value(creature.data.food, 0, creature.data.max_food, 0, food_n)
	var stamina = remap_and_quantize_value(creature.data.stamina, 0, creature.data.max_stamina, 0, stamina_n)

	var state = LowLevelState.new(health, food, stamina)

	# First a dist check
	var res = {}
	for prop in zone_props.get_children():
		if not prop.is_in_group("Food"):
			continue

		#DEBUG
		items.append(prop)

		var dist = creature.global_position.distance_to(prop.global_position)
		res[prop] = dist

	var temp = res.values()
	var best_res = []
	if not temp.is_empty():
		temp.sort()
		var threshold = astar_threshold if temp.size() > astar_threshold else temp.size()
		var cut_value = temp[threshold - 1]
		for i in res.keys():
			if res[i] < cut_value:
				best_res.append(i)

	# Then a path check for the best results
	for prop in best_res:
		if not is_instance_valid(prop):
			continue
		
		var creature_node = creature.ai.astar_graph.tmhelper.to_local_position(creature.global_position)
		var prop_node = creature.ai.astar_graph.tmhelper.to_local_position(prop.global_position)

		if not creature.ai.astar_graph.astar_nodes.has(creature_node):
			creature.ai.on_current_node_missing.emit(creature)
		
		#TODO Do the same with prop

		var cost = creature.global_position.distance_to(prop.global_position)

		var path = await creature.ai.astar_ai.astar(creature_node, prop_node)
		if not path.is_empty():
			cost = creature.ai.astar_ai.get_total_cost_from_path(path)
		
		# Need to repeat the checks due to the yield
		if not is_instance_valid(prop):
			continue

		var dist = remap_and_quantize_value(cost, 0, max_considerable_distance, 0, dist_n)

		var food_value = remap_and_quantize_value(prop.food_value, 0, max_considerable_food_value, 0, food_value_n)

		var food_item = LowLevelState.Food.new(dist, food_value)
		item_node[food_item] = prop
	
		state.visible_items.append(food_item)


	# First a dist check
	res = {}
	for prop in zone_props.get_children():
		if not prop.is_in_group("Creature"):
			continue

		if not prop in creatures:
			creatures.append(prop)

		if prop == creature:
			continue

		#DEBUG
		items.append(prop)

		var dist = creature.global_position.distance_to(prop.global_position)
		res[prop] = dist

	temp = res.values()
	best_res = []
	if not temp.is_empty():
		temp.sort()
		var threshold = astar_threshold if temp.size() > astar_threshold else temp.size()
		var cut_value = temp[threshold - 1]
		for i in res.keys():
			if res[i] < cut_value:
				best_res.append(i)

	# Then a path check for the best results
	for prop in best_res:
		if not is_instance_valid(prop):
			continue

		var creature_node = creature.ai.astar_graph.tmhelper.to_local_position(creature.global_position)
		var prop_node = creature.ai.astar_graph.tmhelper.to_local_position(prop.global_position)

		if not creature.ai.astar_graph.astar_nodes.has(creature_node):
			creature.ai.on_current_node_missing.emit(creature)

		var cost = creature.global_position.distance_to(prop.global_position)
		
		var path = await creature.ai.astar_ai.astar(creature_node, prop_node)
		if not path.is_empty():
			cost = creature.ai.astar_ai.get_total_cost_from_path(path)
		
		# Need to repeat the checks due to the yield
		if not is_instance_valid(prop):
			continue

		var dist = remap_and_quantize_value(cost, 0, max_considerable_distance, 0, dist_n)

		#TODO how to calculate food value for creatures?
		var food_value = remap_and_quantize_value(0, 0, max_considerable_food_value, 0, food_value_n)
		# Threat level = health * attack power
		var threat_level = remap_and_quantize_value(prop.data.health * prop.data.attack_power, 0, creature.data.max_health * max_considerable_attack_power, 0, threat_level_n)

		var creature_item = LowLevelState.OtherCreature.new(dist, food_value, threat_level)
		item_node[creature_item] = prop

		state.visible_items.append(creature_item)

	#DEBUG
	if debug:
		print("\n")
		print("State for creature ", creature.name)
		print("Health: ", state.health)
		print("Food: ", state.food)
		print("Stamina: ", state.stamina)
		for item in state.visible_items:
			print(item)
		print("\n")

	return state


func remap_and_quantize_value(value, old_min, old_max, new_min, new_max):
	var v = value
	if value > old_max:
		v = old_max
	if value < old_min:
		v = old_min
	var new_value = new_min + (v - old_min) * (new_max - new_min) / (old_max - old_min)
	var quantized_value = floor(new_value)
	if quantized_value == new_max:
		quantized_value -= 1
	return quantized_value
	
func get_item_node(item) -> Node2D:
	if not is_instance_valid(item_node[item]):
		return null
	return item_node[item]

func get_creature_tl(creature) -> int:
	return (creature.data.health * creature.data.attack_power) / (max_considerable_attack_power * 100) #HACK

#DEBUG
var items = []

func _process(delta: float) -> void:
	queue_redraw()

func _draw():
	# Get rid of deleted items
	var new_items = []
	for item in items:
		if item:
			new_items.append(item)
	items = new_items

	for item in items:
		if not item:
			continue
		for creature in creatures:
			if not is_instance_valid(creature):
				continue
			
			var color
			if item.is_in_group("Food"):
				color = Color(1, 0, 0)
			elif item.is_in_group("Creature"):
				color = Color(0, 0, 1)

			var creature_pos = creature.global_position - self.global_position
			var item_pos = item.global_position - self.global_position

			var dist = remap_and_quantize_value(creature_pos.distance_to(item_pos), 0, max_considerable_distance, 0, dist_n)
			if dist == 0:
				color *= 0.25
			elif dist == 1:
				color *= 0.5
			elif dist == 2:
				color *= 0.75
			elif dist == 3:
				color *= 1.0

			if debug:
				draw_line(creature_pos, item_pos, color, 1.5)

				var direction = (item_pos - creature_pos).normalized()
				var arrowhead1 = item_pos - direction * 20 + direction.rotated(PI / 2) * 10
				var arrowhead2 = item_pos - direction * 20 - direction.rotated(PI / 2) * 10
				draw_line(item_pos, arrowhead1, color, 1.5)
				draw_line(item_pos, arrowhead2, color, 1.5)

			if creature.ai.target:
				draw_line(creature_pos, creature.ai.target - self.global_position, Color(1, 1, 1), 3)
