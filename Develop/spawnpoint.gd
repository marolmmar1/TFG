extends Marker2D

@export var creature: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	creature.instantiate()