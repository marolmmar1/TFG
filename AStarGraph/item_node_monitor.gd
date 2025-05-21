extends Node

@onready var tmhelper = $"../TileMapHelper"

var astar_graph
var zone_props

var temporary_nodes = {} # Item : Node

func init(_astar_graph, _zone):
	astar_graph = _astar_graph
	zone_props = _zone.zone_props

	_zone.on_creature_enter.connect(func(creature): creature.ai.on_current_node_missing.connect(on_creature_node_missing))

	for creature in _zone.get_all_creatures():
		creature.ai.on_current_node_missing.connect(on_creature_node_missing)

func _process(delta):

	if not astar_graph:
		return

	var current_items = zone_props.get_children()

	# Erase deleted
	var new = {}
	for item in temporary_nodes:
		if is_instance_valid(item) and current_items.has(item):
			new[item] = temporary_nodes[item]
		else:
			if temporary_nodes[item] != null:
				astar_graph.delete_node(temporary_nodes[item], 7.5)

	temporary_nodes = new
	
	for item in current_items:

		if not item.is_in_group("Creature") and not item.is_in_group("Food"):
			continue

		if not temporary_nodes.has(item):
			temporary_nodes[item] = null

		var pos = tmhelper.to_local_position(item.global_position)
		if temporary_nodes[item] != pos:
			update_node(item, pos)


func update_node(_item, pos):
	if temporary_nodes[_item]:
		astar_graph.delete_node(temporary_nodes[_item], 7.5)
		temporary_nodes[_item] = null
	
	if not astar_graph.astar_nodes.has(pos):
		temporary_nodes[_item] = pos
		astar_graph.add_node(pos, 5.0)


func on_creature_node_missing(creature):
	print("creature node missing")
	var current_items = zone_props.get_children()
	if creature not in current_items:
		return

	if not creature.check_is_on_floor() and not creature.check_is_on_wall():
		return
	var pos = tmhelper.to_local_position(creature.global_position)
	update_node(creature, pos)	
