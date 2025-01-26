extends Node


const FACE = preload("res://AStar/face.tscn")
var cell_size = 8
var tileMap : TileMap
var graph


func _ready():
	graph = AStar2D.new()
	tileMap = find_parent("Bioma").find_child("TileMap")
	createMap()

func createMap():
	var cells = tileMap.get_used_cells(0)
	for cell in cells:
		var above= Vector2(cell[0], cell[1]-1)
		if !(above in cells):
			var face  = FACE.instance()
			face.position = tileMap.map_to_world(above) + Vector2(cell_size/2)
			pass

