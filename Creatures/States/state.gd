extends Node
class_name State

var controller: CharacterBody2D
var locked := false

signal on_change_state(state, vars)

func init(_controller: CharacterBody2D):
	self.controller = _controller

func enter(vars):
	pass

func exit():
	pass

func tick(delta):
	pass

func check_conditions(vars) -> bool:
	return true

func change_state(state: State, vars):
	on_change_state.emit(state, vars)