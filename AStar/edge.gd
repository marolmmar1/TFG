
class_name Edge

enum MovementType {
    WALK, CLIMB, CRAWL, FALL, SWITCH_CLIMBING, SWITCH_AND_CRAWL, JUMP
}

var from: Vector2i
var to: Vector2i
var movement_type: MovementType

func _init(from_node: Vector2i, to_node: Vector2i, type: MovementType):
    self.from = from_node
    self.to = to_node
    self.movement_type = type
