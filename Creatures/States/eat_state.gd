extends State

@export var eat_range := 20
@export var time_per_bite := 0.8
@export var food_per_bite := 20

@onready var idle_state = $"../Idle"

var food
var time

func enter(vars):
	if vars.has("food"):
		food = vars["food"]

	time = 0

func tick(delta):
	time += delta

	if time >= time_per_bite:
		time = 0
		if not is_instance_valid(food):
			return
		
		if food.food_value >= food_per_bite:
			controller.data.food += food_per_bite
			food.food_value -= food_per_bite
		else:
			controller.data.food += food.food_value
			food.food_value = 0

		if food.food_value <= 0:
			food.deplete()
			on_change_state.emit(idle_state, {})

func check_conditions(vars) -> bool:
	if (controller.check_is_on_floor() or controller.check_is_on_wall()) and vars.has("food") and vars["food"] != null and controller.global_position.distance_to(vars["food"].global_position) < eat_range:
		return true
	
	return false

func exit():
	pass
