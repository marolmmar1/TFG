extends Control

@onready var health_bar:ProgressBar = $HealthBar
@onready var food_bar:ProgressBar = $FoodBar
@onready var stamina_bar:ProgressBar = $StaminaBar
@onready var low_level_label:Label = $LowLevelLabel
@onready var state_lavel:Label = $StateLabel
@onready var camera:Camera2D = get_viewport().get_camera_2d()

@export var character: CharacterBody2D
@export var fill_speed = 5.0

func _process(delta):
	if not character or not camera:
		return
	position = (camera.get_global_transform().affine_inverse() * character.global_position + get_viewport().get_visible_rect().size / (2 * camera.zoom)) * camera.zoom

	if character.data:
		health_bar.value = lerp(health_bar.value, character.data.health / character.data.max_health * 100.0, delta * fill_speed)
		food_bar.value = lerp(food_bar.value, character.data.food / character.data.max_food * 100.0, delta * fill_speed)
		stamina_bar.value = lerp(stamina_bar.value, character.data.stamina / character.data.max_stamina * 100.0, delta * fill_speed)

	if character.ai.current_low_level_action:
		low_level_label.text = character.ai.current_low_level_action.name.split("Action")[0]

	if character.controller.current_state:
		state_lavel.text = character.controller.current_state.name