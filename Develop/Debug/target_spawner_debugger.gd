extends Node2D

@export var update_radius: float = 5.0

@export var astar_graph: Node2D
@export var creature: Node2D

var guard := true
var target
var is_target_temporary

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and guard:
		if target and is_target_temporary:
			astar_graph.delete_node(astar_graph.tmhelper.to_local_position(target), update_radius)
		
		target = get_global_mouse_position()
		is_target_temporary = not astar_graph.astar_nodes.has(astar_graph.tmhelper.to_local_position(target))

		astar_graph.add_node(astar_graph.tmhelper.to_local_position(target), update_radius)
		
		creature.target = target

		guard = false
		get_tree().create_timer(1.0).timeout.connect(func(): guard = true)
	
