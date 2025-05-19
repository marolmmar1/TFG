extends Node

var low_level_state_manager

#TODO probably should detach further from the actual AI algorithm, greedy or otherwise
# Also add an action as a parameter and make something with that

var chromosome = {
	"attack": {
		"threat_mod": 1.0, 
		"dist_mod": 1.0, 
		"food_value_mod": 1.0, 
		"health_mod": 1.0,
		"food_mod": 1.0,
		"stamina_mod": 1.0,
	},
	"flee": {
		"threat_mod": 1.0, 
		"dist_mod": 1.0, 
		"health_mod": 1.0,
		"food_mod": 1.0,
		"stamina_mod": 1.0,
	},
	"eat": {	
		"threat_mod": 1.0,
		"dist_mod": 1.0, 
		"food_value_mod": 1.0, 
		"health_mod": 1.0,
		"food_mod": 1.0,
		"stamina_mod": 1.0,
	},
	"jump_reliability_cost_mult": 1.0,
	"fall_reliability_cost_mult": 1.0,
	"threat_base_cost": 100.0
}

func init(_low_level_state_manager, astar_ai):
	low_level_state_manager = _low_level_state_manager
	astar_ai.jump_reliability_cost_mult = chromosome.jump_reliability_cost_mult
	astar_ai.fall_reliability_cost_mult = chromosome.fall_reliability_cost_mult
	astar_ai.threat_base_cost = chromosome.threat_base_cost

func calculate_action(state: LowLevelState) -> LowLevelAction:
	var action_scores = {}

	action_scores[["rest", null]] = 0

	for item in state.visible_items:
		if item is LowLevelState.OtherCreature:
			action_scores[["flee", item]] = item.threat_level * chromosome.flee.threat_mod + item.dist * chromosome.flee.dist_mod + \
				state.health * chromosome.flee.health_mod + state.food * chromosome.flee.food_mod + state.stamina * chromosome.flee.stamina_mod

			action_scores[["attack", item]] = item.threat_level * chromosome.attack.threat_mod + item.dist * chromosome.attack.dist_mod + \
				item.food_value * chromosome.attack.food_value_mod + \
				state.health * chromosome.attack.health_mod + state.food * chromosome.attack.food_mod + state.stamina * chromosome.attack.stamina_mod
		
		elif item is LowLevelState.Food:
			action_scores[["eat", item]] = item.food_value * chromosome.eat.food_value_mod + item.dist * chromosome.eat.dist_mod + \
				state.health * chromosome.eat.health_mod + state.food * chromosome.eat.food_mod + state.stamina * chromosome.eat.stamina_mod

	var best_action = ["rest", null]
	for action in action_scores.keys():
		if action_scores[action] > action_scores[best_action]:
			best_action = action

	if best_action[0] == "attack":
		return AttackAction.new(best_action[1])
	elif best_action[0] == "flee":
		return FleeAction.new(best_action[1])
	elif best_action[0] == "eat":
		return EatAction.new(best_action[1])
	else:
		return RestAction.new()
