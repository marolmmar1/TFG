extends LowLevelAction

class_name EatAction

var food

func _init(_food) -> void:
    food = _food

func execute(mainAI):
    #HACK arguably not a good way to access it but it's unlikely to break
    mainAI.target = mainAI.low_level_state_manager.get_item_node(food).position