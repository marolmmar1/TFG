extends Node


@onready var astar_graph = get_parent()
@onready var tmhelper = $"../TileMapHelper"

var temporary_nodes = {}
var creature: Node2D #DEBUG

func init(_creature):
	creature = _creature
	temporary_nodes[creature] = null
	update_node(creature, tmhelper.to_local_position(creature.position))

func _process(delta):
	
	#TODO loop through all creatures from state

	var pos = tmhelper.to_local_position(creature.position)
	if temporary_nodes[creature] != pos:
		update_node(creature, pos)

func update_node(_creature, pos):
	if temporary_nodes[_creature]:
		astar_graph.delete_node(temporary_nodes[_creature], 7.5)
		temporary_nodes[_creature] = null
	
	if not astar_graph.astar_nodes.has(pos):
		temporary_nodes[_creature] = pos
		astar_graph.add_node(pos, 5.0)
