extends Node

@export var stun_height: float = 350
@export var damage_height: float = 550
@export var default_stun_time: float = 1.5
#DEBUG
@export var debug := false

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
@onready var stun_state = $Stunned
@onready var eat_state = $Eat
@onready var rest_state = $Rest
@onready var attack_state = $Attack

var controller: CharacterBody2D
var last_vel
var gravity
var current_state: State
var current_vars = {}
var queued_state: State
var queued_vars = {}

var position:
	get:
		return controller.global_position
	set(value):
		assert(false)

signal on_change_state(state)

func init(_controller: CharacterBody2D, vars):
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
	stun_state.init(controller)
	stun_state.on_change_state.connect(change_state)
	eat_state.init(controller)
	eat_state.on_change_state.connect(change_state)
	rest_state.init(controller)
	rest_state.on_change_state.connect(change_state)
	attack_state.init(controller)
	attack_state.on_change_state.connect(change_state)

	gravity = fall_state.gravity

	#TODO set up all movement vars
	# if vars.has("eat range"):
	# 	eat_range = vars["eat range"]

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
			if debug:
				print(controller.name, " physics state: ", current_state.name)
			on_change_state.emit(current_state)
		elif idle_state.check_conditions({}):
			current_state = idle_state
			idle_state.enter({})
			if debug:
				print(controller.name, " physics state: ", current_state.name)
			on_change_state.emit(current_state)
	

	# Fall damage or stun
	if controller.get_slide_collision_count() > 0:
		if not gravity:
			return

		# v = sqrt(2 * g * h)
		if last_vel.length() > sqrt(2 * gravity * damage_height):
			current_state = stun_state
			stun_state.enter({"stun time": default_stun_time})
			# print("damage")
			on_change_state.emit(current_state)
		
		elif last_vel.length() > sqrt(2 * gravity * stun_height):
			current_state = stun_state
			stun_state.enter({"stun time": default_stun_time})
			# print("stun")
			on_change_state.emit(current_state)

			# TODO: Apply damage
			# TODO account for normal direction on impact

			# TODO not sure how to handle collision with innert moving objects. Maybe the object should call the creature, maybe we should be checking here 
			# through a node interface			


	last_vel = controller.velocity


func change_state(_state, vars):

	if queued_state and queued_state.check_conditions(queued_vars): # Just to avoid possible state flickering
		_switch_to_queued_state()

	elif _state.check_conditions(vars):
		current_state.exit()
		current_state = _state
		current_vars = vars
		if debug:
			print(controller.name, " physics state: ", current_state.name)
		current_state.enter(current_vars)
		on_change_state.emit(current_state)


func _switch_to_queued_state():
	current_state.exit()
	current_state = queued_state
	current_vars = queued_vars
	if debug:
		print(controller.name, " physics state: ", current_state.name)
	queued_state = null
	queued_vars = {}
	current_state.enter(current_vars)
	on_change_state.emit(current_state)


func queue_change_state(state, vars):
	
	if queued_state == state and queued_vars == vars:
		return
	elif current_state == state and current_vars == vars:
		return

	if debug:
		print(controller.name, " physics queue change state: ", state.name)

	
	queued_state = state
	queued_vars = vars
