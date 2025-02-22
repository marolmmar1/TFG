extends CharacterBody2D

@export_category("Main")
@export var ai_time = 0.5

@export_category("Provided")
@export var astar: Node2D

@export_category("Debug")
@export var target: Node2D

@onready var controller = $Controller
@onready var ai = $AI
@onready var ai_timer: Timer = $AITimer

func _ready() -> void:

	controller.init(self)
	ai.init(astar, controller, target)

	# ai_timer.wait_time = ai_time
	# ai_timer.timeout.connect(ai_tick)
	# ai_timer.start()

func _process(delta: float) -> void:
	ai_tick()

func ai_tick():
	ai.tick()
	# ai_timer.start()