
class_name Edge

enum MovementType {
    WALK, CLIMB, CRAWL, SWITCH_CLIMBING, SWITCH_CRAWL_WALK, SWITCH_CRAWL_CLIMB, JUMP, FALL
}

var from: Vector2i
var to: Vector2i
var movement_type: MovementType
var temporary: bool = false
var double_temporary: bool = false

func _init(from_node: Vector2i, to_node: Vector2i, type: MovementType):
    self.from = from_node
    self.to = to_node
    self.movement_type = type
