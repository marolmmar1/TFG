extends ActionController

var creature
var target_pos
var nodes

func enter(mainAI, target = null):
	mainAI.on_target_reached.connect(on_target_reached)
	creature = target
	nodes = mainAI.astar_graph.astar_nodes
	target_pos = await get_lowest_tl_node(creature, nodes)
	
func execute(mainAI):
	if target_pos:
		mainAI.target = target_pos

func exit(mainAI):
	mainAI.on_target_reached.disconnect(on_target_reached)

func on_target_reached():
	on_action_finished.emit()

func get_lowest_tl_node(_creature, _nodes):	
	var max_dist = 0
	var res_node
	for node in _nodes:
		var path = await _creature.ai.astar_ai.astar(_creature.ai.astar_graph.tmhelper.to_local_position(_creature.position), node)
		var dist = _creature.ai.astar_ai.get_total_cost_from_path(path)

		if dist > max_dist:
			max_dist = dist
			res_node = node

	if not res_node:
		return null
	return _creature.ai.astar_graph.tmhelper.to_world_position(res_node)
