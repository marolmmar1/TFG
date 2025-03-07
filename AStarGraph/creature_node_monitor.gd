extends Node


@onready var astar_graph = get_parent()
@onready var tmhelper = $"../TileMapHelper"

var temporary_nodes = {}

func _process(delta):
	
	for creature in astar_graph.get_parent().get_children():

		if not creature.is_in_group("Creature"):
			continue

		if not temporary_nodes.has(creature):
			temporary_nodes[creature] = null

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
