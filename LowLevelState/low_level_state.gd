
class_name LowLevelState

class Food:
    var dist: int
    var food_value: int

    func _init(_dist: int, _food_value: int):
        dist = _dist
        food_value = _food_value

    func _to_string():
        return "Food | dist: " + str(dist) + ", food_value: " + str(food_value)

class OtherCreature:
    var dist: int
    var food_value: int
    var threat_level: int

    func _init(_dist: int, _foodValue: int, _threat_level: int):
        dist = _dist
        food_value = _foodValue
        threat_level = _threat_level

    func _to_string():
        return "Other Creature | dist: " + str(dist) + ", foodValue: " + str(food_value) + ", threat_level: " + str(threat_level)

var health: int
var food: int
var stamina: int

var visible_items = []

func _init(_health: int, _food: int, _stamina: int):
    health = _health
    food = _food
    stamina = _stamina