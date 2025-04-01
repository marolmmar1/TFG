extends LowLevelAction

class_name AttackAction

var enemy

func _init(_enemy) -> void:
    enemy = _enemy

func _to_string() -> String:
    return "Attack | enemy: " + str(enemy)