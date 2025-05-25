extends Node2D
class_name HighLevelStateManager

#función get_state(creature): devuelve el estado de alto nivel en función de una criatura

func get_state(creature:CreatureData) -> HighLevelState:   
	var current_zone = HighLevelState.Zone.new(creature.current_zone, creature.current_zone.threat_level, creature.current_zone.food_amount, 0)
	var parsed_zone
	var zones = []
	var state = HighLevelState.new(creature.max_health,creature.max_food,creature.max_stamina,creature.health, creature.food, creature.stamina, current_zone,[])
	for key in creature.memory.keys():
		if not typeof(key) == TYPE_STRING:
			var zone = key
			if not zone == creature.current_zone:
				parsed_zone= HighLevelState.Zone.new(zone, zone.threat_level, zone.food_amount, 0)
				parsed_zone.distance = parsed_zone._get_distance(current_zone, parsed_zone)
				state.zones.append(parsed_zone)
	return state	
