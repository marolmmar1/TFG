extends ActionController

var target

var can_attack := false

func enter(mainAI, _target = null):
	target = _target
	can_attack = false
	mainAI.on_target_reached.connect(on_target_reached)


func execute(mainAI):
	mainAI.target = target.global_position
	
	if can_attack:
		mainAI.attack(target)
		if not target:
			on_action_finished.emit()

func exit(mainAI):
	mainAI.on_target_reached.disconnect(on_target_reached)

func on_target_reached():
	can_attack = true
