class_name FiniteStateMachine
extends Node

@export var state: State

func _ready():
	change_state(state)

func change_state(new_state: State):
	if state is State:
		state.exit_state(state)
	new_state.enter_state(state)
	state = new_state
