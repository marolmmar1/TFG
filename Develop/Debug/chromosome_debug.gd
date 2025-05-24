extends Control

@onready var label = $Label

signal on_chromosome_selected(chromosome)

#Lo de 0.75 es tremendo #HACK pero bueno funciona y este código no es que sea especialmente relevante

func _ready() -> void:
	on_chromosome_selected.connect(_show)
	var pos = Vector2(get_viewport().get_visible_rect().size.x * 1.15, position.y); 
	self.position = pos
	self.visible = true

func _on_hide_button_down() -> void:
	var pos = Vector2(get_viewport().get_visible_rect().size.x * 1.1, position.y); 
	get_tree().create_tween().tween_property(self, "position", pos, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func _show(chromosome):
	var text = str(chromosome)
	text = text.replace(",", ",\n")
	text = text.replace("{", "{\n")
	text = text.replace("}", "}\n")
	label.text = text

	var pos = Vector2(get_viewport().get_visible_rect().size.x * 0.75, position.y); 
	get_tree().create_tween().tween_property(self, "position", pos, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)