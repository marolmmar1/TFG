class_name State
extends Node

signal on_change_state(next_state)

func _ready()->void:
	self.process_mode = Node.PROCESS_MODE_DISABLED

func enter_state(state) -> void:
	self.process_mode = Node.PROCESS_MODE_INHERIT

func exit_state(new_state:State) ->void:
	self.process_mode = Node.PROCESS_MODE_DISABLED
	on_change_state.emit(new_state)
