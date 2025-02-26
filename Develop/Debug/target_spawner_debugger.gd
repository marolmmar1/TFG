extends Node2D

@export var update_radius: float = 5.0

@export var astar_graph: Node2D
@export var creature: Node2D

var guard := true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and guard:
		var target = get_global_mouse_position()
		astar_graph.add_node(target, update_radius)
		
		creature.target = target

		guard = false
		get_tree().create_timer(1.0).timeout.connect(func(): guard = true)
	
