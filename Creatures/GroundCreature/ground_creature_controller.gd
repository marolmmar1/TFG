extends Node

@export var speed: float = 100.0
@export var climb_speed: float = 80.0
@export var gravity: float = 500.0
@export var jump_force: float = -200.0

@onready var idle_state = $Idle
@onready var idle_climb_state = $IdleClimb
@onready var idle_crawl_state = $IdleCrawl
@onready var fall_state = $Fall
@onready var walk_state = $Walk
@onready var climb_state = $Climb
@onready var crawl_state = $Crawl
@onready var switch_climbing_state = $SwitchClimbing
@onready var switch_crawl_walk_state = $SwitchCrawlWalk
@onready var switch_crawl_climb_state = $SwitchCrawlClimb
@onready var jump_state = $Jump

var controller: CharacterBody2D
var current_state: State
var current_vars = {}
var queued_state: State
var queued_vars = {}

var position:
	get:
		return controller.position
	set(value):
		assert(false)

func init(_controller: CharacterBody2D):
	self.controller = _controller

	# idle_state.init(controller)
	# idle_state.on_change_state.connect(change_state)
	# idle_climb_state.init(controller)
	# idle_climb_state.on_change_state.connect(change_state)
	# idle_crawl_state.init(controller)
	# idle_crawl_state.on_change_state.connect(change_state)
	fall_state.init(controller)
	fall_state.on_change_state.connect(change_state)
	walk_state.init(controller)
	walk_state.on_change_state.connect(change_state)
	climb_state.init(controller)
	climb_state.on_change_state.connect(change_state)
	crawl_state.init(controller)
	crawl_state.on_change_state.connect(change_state)
	switch_climbing_state.init(controller)
	switch_climbing_state.on_change_state.connect(change_state)
	switch_crawl_walk_state.init(controller)
	switch_crawl_walk_state.on_change_state.connect(change_state)
	switch_crawl_climb_state.init(controller)
	switch_crawl_climb_state.on_change_state.connect(change_state)
	jump_state.init(controller)
	jump_state.on_change_state.connect(change_state)

func _physics_process(delta: float):
	if not controller:
		return

	if queued_state and not current_state.locked and queued_state.check_conditions(queued_vars):
		_switch_to_queued_state()
	
	if current_state:
		current_state.tick(delta)

	else:
		if fall_state.check_conditions({}):
			current_state = fall_state
			fall_state.enter({})
			print(current_state.name)
		elif idle_state.check_conditions({}):
			current_state = idle_state
			idle_state.enter({})
			print(current_state.name)


func change_state(_state, vars):

	if queued_state and queued_state.check_conditions(queued_vars): #Just to avoid possible state flickering
		_switch_to_queued_state()

	elif _state.check_conditions(vars):
		current_state.exit()
		current_state = _state
		current_vars = vars
		print(current_state.name)
		current_state.enter(current_vars)


func _switch_to_queued_state():
	current_state.exit()
	current_state = queued_state
	current_vars = queued_vars
	print(current_state.name)
	queued_state = null
	queued_vars = {}
	current_state.enter(current_vars)


func queue_change_state(state, vars):
	
	if queued_state == state and queued_vars == vars:
		return
	elif current_state == state and current_vars == vars:
		return

	print("queue_change_state: ", state.name)

	queued_state = state
	queued_vars = vars
