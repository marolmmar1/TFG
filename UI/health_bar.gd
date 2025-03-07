extends Control

@onready var health_bar:ProgressBar = $HealthBar
@onready var food_bar:ProgressBar = $FoodBar
@onready var stamina_bar:ProgressBar = $StaminaBar

@export var character: CharacterBody2D
@export var fill_speed = 5.0

func _process(delta):
	position = character.global_position

	if character.data:
		health_bar.value = lerp(health_bar.value, character.data.health, delta * fill_speed)
		food_bar.value = lerp(food_bar.value, character.data.food, delta * fill_speed)
		stamina_bar.value = lerp(stamina_bar.value, character.data.stamina, delta * fill_speed)
