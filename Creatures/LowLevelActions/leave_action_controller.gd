extends ActionController

var target_node

func enter(mainAI, target = null):
    target_node = target
    mainAI.on_target_reached.connect(on_target_reached)

func execute(mainAI):
    mainAI.target = target_node

func exit(mainAI):
    mainAI.on_target_reached.disconnect(on_target_reached)

func on_target_reached():
    on_action_finished.emit()