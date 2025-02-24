extends Node2D

class_name Zone

@onready var doors = $Doors.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	print(doors)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
