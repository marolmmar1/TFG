extends Node

var low_level_state_manager

@onready var greedy = $Greedy
@onready var genetic = $Genetic

func init(_low_level_state_manager):
	low_level_state_manager = _low_level_state_manager

	greedy.low_level_state_manager = low_level_state_manager
	genetic.low_level_state_manager = low_level_state_manager

func calculate_action(state: LowLevelState) -> LowLevelAction:

	return greedy.calculate_action(state)
	# return genetic.calculate_action(state)
