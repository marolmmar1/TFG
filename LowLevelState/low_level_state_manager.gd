extends Node2D

@export var healt_n: int = 4
@export var food_n: int = 4
@export var stamina_n: int = 4
@export var dist_n: int = 4
@export var max_considerable_distance: float = 1000
@export var food_value_n: int = 4
@export var max_food_value: float = 100
@export var threat_level_n: int = 4


var item_node = {}


func get_state(creature) -> LowLevelState:
	#DEBUG
	creature_debug = creature

	var health = remap_and_quantize_value(creature.data.health, 0, creature.data.max_health, 0, healt_n)
	var food = remap_and_quantize_value(creature.data.food, 0, creature.data.max_food, 0, food_n)
	var stamina = remap_and_quantize_value(creature.data.stamina, 0, creature.data.max_stamina, 0, stamina_n)

	var state = LowLevelState.new(health, food, stamina)

	for node in get_parent().get_children():
		if not node.is_in_group("Food"):
			continue

		# #DEBUG
		# foods.append(node)

		var dist = remap_and_quantize_value(creature.global_position.distance_to(node.global_position), 0, max_considerable_distance, 0, dist_n)
		var food_value = remap_and_quantize_value(node.food_value, 0, max_food_value, 0, food_value_n)

		var food_item = LowLevelState.Food.new(dist, food_value)
		item_node[food_item] = node
	
		state.visible_items.append(food_item)

	for node in get_parent().get_children():
		if not node.is_in_group("Creature"):
			continue

		var dist = remap_and_quantize_value(creature.global_position.distance_to(node.global_position), 0, max_considerable_distance, 0, dist_n)
		#TODO how to calculate food value for creatures?
		var food_value = remap_and_quantize_value(0, 0, max_food_value, 0, food_value_n)
		# Threat level = health * attack power
		var threat_level = remap_and_quantize_value(node.data.health * node.data.attack_power, 0, node.data.max_health * node.data.attack_power, 0, threat_level_n)

		var creature_item = LowLevelState.OtherCreature.new(dist, food_value, threat_level)
		item_node[creature_item] = node

		state.visible_items.append(creature_item)

	#DEBUG
	queue_redraw()

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
var creature_debug
var foods = []
func _draw():
	if foods and creature_debug:
		for food in foods:
			draw_line(creature_debug.global_position, food.global_position, Color.BLUE, 2)
