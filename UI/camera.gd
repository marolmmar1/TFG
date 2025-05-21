extends Camera2D

@export var zoom_step := 0.1
@export var min_zoom := 0.1
@export var max_zoom := 3.0
@export var speed := 1.0
var dragging := false
var last_mouse_position := Vector2.ZERO

func _unhandled_input(event):
    # Handle mouse drag
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            dragging = event.pressed
            last_mouse_position = event.position

        # Handle mouse wheel zoom
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            _zoom_camera(-zoom_step)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            _zoom_camera(zoom_step)

    elif event is InputEventMouseMotion and dragging:
        var delta = last_mouse_position - event.position
        position += delta * speed * 1/zoom
        last_mouse_position = event.position

func _zoom_camera(amount: float):
    var new_zoom = zoom - Vector2(amount, amount)
    new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
    new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
    zoom = new_zoom
