extends Node2D

@export var healt_n: int = 4
@export var food_n: int = 4
@export var stamina_n: int = 4
@export var dist_n: int = 4
@export var max_considerable_distance: float = 1000
@export var food_value_n: int = 4
@export var max_food_value: float = 100


func get_state(creature) -> LowLevelState:
	var data = creature.data
	var health = remap_and_quantize_value(data.health, 0, data.maxHealth, 0, healt_n)
	var food = remap_and_quantize_value(data.food, 0, data.maxHunger, 0, food_n)
	var stamina = remap_and_quantize_value(data.stamina, 0, data.maxStamina, 0, stamina_n)

	var state = LowLevelState.new(health, food, stamina)

	for node in get_tree().get_nodes_in_group("Food"):
		var dist = remap_and_quantize_value(data.global_position.distance_to(node.global_position), 0, max_considerable_distance, 0, dist_n)
		var foodValue = remap_and_quantize_value(node.foodValue, 0, max_food_value, 0, food_value_n)

		state.visible_items.append(LowLevelState.Food.new(dist, foodValue))

	return state

func remap_and_quantize_value(value, min, max, new_min, new_max):
	var v = value
	if value > max:
		v = max
	if value < min:
		v = min
	var new_value = new_min + (v - min) * (new_max - new_min) / (max - min)
	var quantized_value = floor(new_value)
	if quantized_value == new_max:
		quantized_value -= 1
	return quantized_value
