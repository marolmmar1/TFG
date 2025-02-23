extends Marker2D

@onready var biome = get_parent()
@export var creature: PackedScene

func _ready():
	var herb = creature.instantiate()
	biome.add_child.call_deferred(herb)