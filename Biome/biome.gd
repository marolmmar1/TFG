extends Node2D

@onready var zones

var zone_graph = {"zones": [], "edges": []}

func _ready():
	zones = get_children().filter(func(x): return x is ZoneClass)
	zone_graph["zones"] = zones
	#Dict where the {zone_id: {"zone": zone, "doors": {"zone_id it ponts to": door itself}}}
	var doors_by_zone = {}
	for zone in zones:
		var zone_id = zone.name.rsplit("_", false, 2)[1]
		doors_by_zone[zone_id]={}
		doors_by_zone[zone_id]["zone"]=zone
		doors_by_zone[zone_id]["doors"]={}
		for door in zone.find_child("Doors").get_children():
			doors_by_zone[zone_id]["doors"][door.name.rsplit("_", false, 2)[2]]= door
	for zone in doors_by_zone.keys():
		for door_data in doors_by_zone[zone]["doors"]:
			var this_door =doors_by_zone[zone]["doors"][door_data]
			if this_door.other_side == null:
				zone_graph["edges"].append([doors_by_zone[zone]["zone"],doors_by_zone[door_data]["zone"]])
				zone_graph["edges"].append([doors_by_zone[door_data]["zone"], doors_by_zone[zone]["zone"]])
				this_door.other_side = doors_by_zone[door_data]["doors"][zone]
				doors_by_zone[door_data]["doors"][zone].other_side = this_door
	var astar = HLAStar.new()
	var path = astar.a_star(zone_graph, zone_graph["zones"][0], zone_graph["zones"][1])
	
	
func _process(delta):
	pass

func  change_zone(body: CharacterBody2D, exit: Door, enter: Door):
	var zone_left = exit.get_parent().get_parent()
	var zone_entered = enter.get_parent().get_parent()
	zone_left.remove_child(body)
	zone_entered.add_child(body)
	body.position = enter.get_node("ExitSpawn").position
	zone_left.visible = false
	zone_entered.visible = true
	
