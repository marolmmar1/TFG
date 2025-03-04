
class_name LowLevelState

class Food:
    var dist: int
    var foodValue: int

    func _init(_dist: int, _foodValue: int):
        dist = _dist
        foodValue = _foodValue

class OtherCreature:
    var dist: int
    var foodValue: int
    var threatLevel: int

    func _init(_dist: int, _foodValue: int, _threatLevel: int):
        dist = _dist
        foodValue = _foodValue
        threatLevel = _threatLevel

var health: int
var food: int
var stamina: int

var visible_items = []

func _init(_health: int, _food: int, _stamina: int):
    health = _health
    food = _food
    stamina = _stamina