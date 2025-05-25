extends Node
class_name HLAStar

func a_star(graph: Dictionary, start: ZoneClass, goal: ZoneClass, markov:Markov = null) -> Array:
	print("astar from: ", start.name, " to: ", goal.name)
	var open_set = [start]  # Nodes to explore
	var came_from = {}  # Tracks the best path

	var g_score = {}  # Cost from start to each node
	var f_score = {}  # Estimated cost from start to goal

	# Initialize scores
	for node in graph["zones"]:
		g_score[node] = INF
		f_score[node] = INF

	g_score[start] = 0
	f_score[start] = heuristic(start, goal)
	

	while open_set.size() > 0:
		# Sort open_set based on f_score (lowest first)
		open_set.sort_custom(func(a, b): return f_score[a] < f_score[b])
		var current = open_set.pop_front()

		if current == goal:
			return reconstruct_path(came_from, current)

		for neighbor in get_neighbors(graph, current):
			var tentative_g_score = 0
			if markov == null:
				tentative_g_score = g_score[current] + get_edge_weight(graph, current, neighbor)
			else:
				tentative_g_score = g_score[current] + 50/markov.q_table[[current, neighbor]]

			if tentative_g_score < g_score[neighbor]:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = g_score[neighbor] + heuristic(neighbor, goal)

				if neighbor not in open_set:
					open_set.append(neighbor)

	return []  # No path found

func reconstruct_path(came_from: Dictionary, current: ZoneClass) -> Array:
	var total_path = [current]
	while current in came_from:
		current = came_from[current]
		total_path.append(current)
	total_path.reverse()
	return total_path

func get_neighbors(graph: Dictionary, zone: ZoneClass) -> Array:
	var neighbors = []
	for edge in graph["edges"]:
		if edge[0] == zone:
			neighbors.append(edge[1])
		elif edge[1] == zone:
			neighbors.append(edge[0])
	return neighbors

func get_edge_weight(graph: Dictionary, zone_a: ZoneClass, zone_b: ZoneClass) -> float:
	for edge in graph["edges"]:
		if graph.keys().has(edge[0]) and graph.keys().has(edge[1]):
			if edge[0] == zone_a and edge[1] == zone_b:
				return float(graph[edge[1]]["threat_level"] ) # Weight is the threat level of the second zone
			elif edge[1] == zone_a and edge[0] == zone_b:
				return float(graph[edge[0]]["threat_level"])
		else:
			if edge[0] == zone_a and edge[1] == zone_b:
				return edge[1].threat_level  # Weight is the threat level of the second zone
			elif edge[1] == zone_a and edge[0] == zone_b:
				return edge[0].threat_level  # Reverse edge case
	return INF  # If edge not found (should not happen)


static func heuristic(a: ZoneClass, b: ZoneClass):
	var tilemap: TileMap = a.get_children()[0]
	var tilemap_distance = get_tilemap_corner_distance(tilemap)
	var distance= abs(abs(a.get_global_position()) - abs(b.get_global_position()))
	return sqrt(distance.x*distance.x+distance.y*distance.y)/tilemap_distance

#TODO: calculate actual distance
static func get_tilemap_corner_distance(tilemap: TileMap) -> float:
	var tilemap_size:float = 1245.14
	return tilemap_size
	