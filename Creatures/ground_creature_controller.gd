extends Node

@export var speed: float = 100.0
@export var climb_speed: float = 80.0
@export var gravity: float = 500.0
@export var jump_force: float = -200.0

@onready var idle_state = $Idle
@onready var idle_wall_state = $IdleWall
@onready var fall_state = $Fall
@onready var walk_state = $Walk
@onready var climb_state = $Climb
@onready var switch_climbing_state = $SwitchClimbing

var controller: CharacterBody2D
var current_state: State
var queued_state = []

var position:
	get:
		return controller.position
	set(value):
		assert(false)

func init(_controller: CharacterBody2D):
	self.controller = _controller

	# idle_state.init(controller)
	# idle_state.on_change_state.connect(change_state)
	# idle_wall_state.init(controller)
	# idle_wall_state.on_change_state.connect(change_state)
	fall_state.init(controller)
	fall_state.on_change_state.connect(change_state)
	walk_state.init(controller)
	walk_state.on_change_state.connect(change_state)
	climb_state.init(controller)
	climb_state.on_change_state.connect(change_state)
	switch_climbing_state.init(controller)
	switch_climbing_state.on_change_state.connect(change_state)


func _physics_process(delta: float):
	if not controller:
		return

	if queued_state and not current_state.locked and queued_state[0].check_conditions(queued_state[1]):
		current_state.exit()
		current_state = queued_state[0]
		current_state.enter(queued_state[1])

	if current_state:
		print(current_state.name)
		current_state.tick(delta)

	else:
		if fall_state.check_conditions({}):
			current_state = fall_state
			fall_state.enter({})
		elif idle_state.check_conditions({}):
			current_state = idle_state
			idle_state.enter({})


func change_state(_state, vars):

	if queued_state and queued_state[0].check_conditions(queued_state[1]): #Just to avoid possible state flickering
		current_state.exit()
		current_state = queued_state[0]
		current_state.enter(queued_state[1])

	if _state.check_conditions(vars):
		current_state.exit()
		current_state = _state
		current_state.enter(vars)

func queue_change_state(_state, vars):
	queued_state = [_state, vars]