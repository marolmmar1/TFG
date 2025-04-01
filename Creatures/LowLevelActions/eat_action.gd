extends LowLevelAction

class_name EatAction

var food

func _init(_food) -> void:
    food = _food

func _to_string() -> String:
    return "Eat | food: " + str(food)