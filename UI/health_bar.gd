extends ProgressBar

@onready var timer = $Timer
@onready var  damage_bar:ProgressBar = $DamageBar

var health = 0
@export var character: CharacterBody2D

func _process(delta):
	position = character.global_position
	damage_bar.position = character.global_position

func _init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _set_health(new_health):
	var prev_health = health
	health = new_health
	value = health
	if health <= 0:	
		queue_free()
	if prev_health > health:
		timer.start()
	else:
		damage_bar.value = health


func _on_timer_timeout():
	damage_bar.value = health
