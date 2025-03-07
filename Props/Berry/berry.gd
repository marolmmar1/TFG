extends Node2D

@export var food_value: float = 5.0

var astar_graph

func _ready() -> void:
	astar_graph = $"../AStarGraph"

	get_tree().create_timer(0.1).timeout.connect(init) #TODO make this not suck

func init():
	astar_graph.add_node(astar_graph.tmhelper.to_local_position(position), 10.0)

