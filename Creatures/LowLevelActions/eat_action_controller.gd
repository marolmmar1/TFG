extends ActionController

var food
var can_eat := false

func enter(mainAI, target = null):
	food = target
	can_eat = false
	mainAI.on_target_reached.connect(on_target_reached)

func execute(mainAI):
	if not food:
		on_action_finished.emit()

	else:
		mainAI.target = food.position

		if can_eat:
			mainAI.eat(food)

func exit(mainAI):
	mainAI.on_target_reached.disconnect(on_target_reached)

func on_target_reached():
	can_eat = true