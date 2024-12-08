class_name FiniteStateMachine
extends Node

@export_category("Provided")
@export var player: CharacterBody3D

@export_category("Main")
@export var state: State

@export_category("DEBUG")


func _ready():
	change_state(state)
	for child in get_children():
		if child is State:
			child.on_change_state.connect(change_state)

func change_state(new_state: State, event=null):
	new_state.enter_state(new_state, event)
	state = new_state
