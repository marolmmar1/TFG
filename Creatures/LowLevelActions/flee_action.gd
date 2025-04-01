extends LowLevelAction

class_name FleeAction

var enemy

func _init(_enemy) -> void:
    enemy = _enemy

func _to_string() -> String:
    return "Flee | enemy: " + str(enemy)