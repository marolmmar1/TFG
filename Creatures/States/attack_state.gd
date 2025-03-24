extends State

enum {WINDUP, ATTACK, RECOIL}

@export var attack_range := 30
@export var windup_time := 0.65
@export var recoil_time := 0.35

@onready var idle_state = $"../Idle"
@onready var debug_sprite = $"../../DebugSprite"

var target
var time
var stage

func enter(vars):	
	if vars.has("target") and vars["target"] != null:
		target = vars["target"]

	stage = WINDUP
	time = 0

func tick(delta):
	time += delta

	if stage == WINDUP:
		windup(delta)
	elif stage == ATTACK:
		attack(delta)
	elif stage == RECOIL:
		recoil(delta)
		
func windup(delta):
	if time >= windup_time:
		stage = ATTACK
		time = 0

func attack(delta):
	var damageable = target.find_children("*", "Damageable")[0]
	if damageable:
		damageable.take_damage(controller, controller.data.attack_power)

	debug_sprite.visible = true
	get_tree().create_timer(0.5).timeout.connect(func(): debug_sprite.visible = false)

	stage = RECOIL

func recoil(delta):
	if time >= recoil_time:
		on_change_state.emit(idle_state, {})

func check_conditions(vars) -> bool:
	if (controller.check_is_on_floor() or controller.check_is_on_wall()) and vars.has("target") and vars["target"] != null and vars["target"].global_position.distance_to(controller.global_position) <= attack_range:
		return true

	return false

func exit():
	pass
