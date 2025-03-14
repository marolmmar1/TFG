extends Node2D

@export var healt_n: int = 3
@export var food_n: int = 3
@export var stamina_n: int = 3
@export var dist_n: int = 4
@export var max_considerable_distance: float = 1000
@export var max_considerable_attack_power: float = 100
@export var food_value_n: int = 4
@export var max_food_value: float = 100
@export var threat_level_n: int = 4

#DEBUG
@export var debug := false

var zone_props


var item_node = {}

func init(_zone):
	zone_props = _zone.zone_props


func get_state(creature) -> LowLevelState:
	#DEBUG
	if not creature in creatures:
		creatures.append(creature)

	if not zone_props:
		return

	var health = remap_and_quantize_value(creature.data.health, 0, creature.data.max_health, 0, healt_n)
	var food = remap_and_quantize_value(creature.data.food, 0, creature.data.max_food, 0, food_n)
	var stamina = remap_and_quantize_value(creature.data.stamina, 0, creature.data.max_stamina, 0, stamina_n)

	var state = LowLevelState.new(health, food, stamina)

	for node in zone_props.get_children():
		if not node.is_in_group("Food"):
			continue

		#DEBUG
		items.append(node)

		var dist = remap_and_quantize_value(creature.global_position.distance_to(node.global_position), 0, max_considerable_distance, 0, dist_n)
		var food_value = remap_and_quantize_value(node.food_value, 0, max_food_value, 0, food_value_n)

		var food_item = LowLevelState.Food.new(dist, food_value)
		item_node[food_item] = node
	
		state.visible_items.append(food_item)

	for node in zone_props.get_children():
		if not node.is_in_group("Creature"):
			continue

		if node == creature:
			continue

		#DEBUG
		items.append(node)

		var dist = remap_and_quantize_value(creature.global_position.distance_to(node.global_position), 0, max_considerable_distance, 0, dist_n)
		#TODO how to calculate food value for creatures?
		var food_value = remap_and_quantize_value(0, 0, max_food_value, 0, food_value_n)
		# Threat level = health * attack power
		var threat_level = remap_and_quantize_value(node.data.health * node.data.attack_power, 0, node.data.max_health * max_considerable_attack_power, 0, threat_level_n)

		var creature_item = LowLevelState.OtherCreature.new(dist, food_value, threat_level)
		item_node[creature_item] = node

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
	return item_node[item]

#DEBUG
var creatures = []
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
			var color
			if item.is_in_group("Food"):
				color = Color(1, 0, 0)
			elif item.is_in_group("Creature"):
				color = Color(0, 0, 1)

			var dist = remap_and_quantize_value(creature.global_position.distance_to(item.global_position), 0, max_considerable_distance, 0, dist_n)
			if dist == 0:
				color *= 0.25
			elif dist == 1:
				color *= 0.5
			elif dist == 2:
				color *= 0.75
			elif dist == 3:
				color *= 1.0

			if debug:
				draw_line(creature.global_position, item.global_position, color, 1.5)

				var direction = (item.global_position - creature.global_position).normalized()
				var arrowhead1 = item.global_position - direction * 20 + direction.rotated(PI / 2) * 10
				var arrowhead2 = item.global_position - direction * 20 - direction.rotated(PI / 2) * 10
				draw_line(item.global_position, arrowhead1, color, 1.5)
				draw_line(item.global_position, arrowhead2, color, 1.5)

			if creature.ai.target:
				draw_line(creature.global_position, creature.ai.target, Color(1, 1, 1), 3)
