class_name FiniteStateMachine
extends Node

@export_category("Provided")
@export var player: CharacterBody3D

@export_category("Main")
@export var state: State

@export_category("DEBUG")


func _ready():
	change_state(state)

func change_state(new_state: State, event=null):
	new_state.enter_state(new_state, event)
	state = new_state

func _on_move_state_on_change_state(next_state, event=null):
	change_state(next_state, event)

func _on_dash_state_on_change_state(next_state, event=null):
	change_state(next_state, event)

func _on_run_state_on_change_state(next_state, event=null):
	change_state(next_state, event)
