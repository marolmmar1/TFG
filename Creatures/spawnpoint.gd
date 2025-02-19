extends Marker2D

@onready var biome = get_parent()
@export var cr_route: PackedScene
@onready var creature = load(cr_route.resource_path)

func _ready():
	var herb = creature.instantiate()
	biome.add_child.call_deferred(herb)
