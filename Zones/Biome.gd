extends Node2D

@onready var zones = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	for zone in zones:
		for door in zone.find_child("Doors").get_children():
			door.on_creature_changes_zone.connect(change_zone)
		if zone.name=="Zone1":
			zone.visible = true
		else:
			zone.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func  change_zone(body: CharacterBody2D, exit: Door, enter: Door):
	var zone_left = exit.get_parent().get_parent()
	var zone_entered = enter.get_parent().get_parent()
	zone_left.remove_child(body)
	zone_entered.add_child(body)
	body.position = enter.position
	zone_left.visible = false
	zone_entered.visible = true
	
