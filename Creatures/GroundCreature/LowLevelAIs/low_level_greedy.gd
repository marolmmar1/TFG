extends Node

var low_level_state_manager

func calculate_action(state: LowLevelState) -> LowLevelAction:

	if get_highest_tl_in_range(state, 0) >= 3:
		return FleeAction.new(get_highest_threat_in_range(state, 0))

	if get_highest_tl_in_range(state, 0) != 0 and get_highest_tl_in_range(state, 0) <= 2 and state.health >= 2:
		return AttackAction.new(get_highest_threat_in_range(state, 0))

	if state.food <= 1 and get_closest_food(state) and not get_highest_tl_in_range(state, 0):
		return EatAction.new(get_closest_food(state))

	if state.food > 0 and state.stamina == 0 and not get_highest_tl_in_range(state, 0):
		return RestAction.new()
	
	#TODO do something for the else?
	return RestAction.new()


# If there are foods in visible items, return the closest one
func get_closest_food(state: LowLevelState):
	if state.visible_items.size() > 0:
		var min_dist = 100000
		var closest_food
		for item in state.visible_items:
			if item is LowLevelState.Food:
				if item.dist < min_dist:
					min_dist = item.dist
					closest_food = item
					
		return closest_food

func get_highest_food_value_in_range(state: LowLevelState, range: int):
	pass

func get_highest_food_in_range(state: LowLevelState, range: int):
	pass

# If there are creatures in visible items, return the highest threat level among them
func get_highest_tl_in_range(state: LowLevelState, range: int):
	if state.visible_items.size() > 0:
		var max_tl = 0
		for item in state.visible_items:
			if item is LowLevelState.OtherCreature:
				if item.dist <= range and item.threat_level > max_tl:
					max_tl = item.threat_level
					
		return max_tl

# If there are creatures in visible items, return the one with the higheset threat level
func get_highest_threat_in_range(state: LowLevelState, range: int):
	if state.visible_items.size() > 0:
		var max_tl = 0
		var highest_threat
		for item in state.visible_items:
			if item is LowLevelState.OtherCreature:
				if item.dist <= range and item.threat_level > max_tl:
					max_tl = item.threat_level
					highest_threat = item
					
		return highest_threat
