class_name FiniteStateMachine
extends Node

@export_category("Provided")
@export var player: CharacterBody3D

@export_category("Main")
@export var state: State

@export_category("DEBUG")


func _ready():
	change_state(state)

func change_state(new_state: State):
	if state is State:
		state.exit_state(state)
	new_state.enter_state(state)
	state = new_state
