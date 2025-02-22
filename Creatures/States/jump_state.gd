extends State

@export var jump_distance: Vector2 = Vector2(120, 90) #HACK hardcoded. Tile size * Astar vars
@export var v_jump_offset: float = 7.5

@onready var fall_state = $"../Fall"

var gravity

func enter(vars):
	gravity = fall_state.gravity
	var target_node = vars["target node"] as Vector2

	# We know that the max v point is target_node.y + v_jump_offset
	# Formula of the max height of a projectile is max_height = v0y^2 / 2*g
	# So v0y = sqrt((target_node.y + v_jump_offset) * 2 * g)
	# Formula of velocity is v = d / t
	# v0x = d_x / total_t
	# Formula of a parabola is y = v0y * t + 0.5 * g * t^2
	# We know final position in y is target_node.y so solving for t we have a quadratic equation:
	# 0.5*g*t^2 + v0y*t - target_node.y = 0
	# t = (-v0y +- sqrt(v0y^2 - 4*0.5*g*-target_node.y)) / 2*0.5*g

	var dist_y = abs(target_node.y - controller.position.y)
	dist_y = min(dist_y, jump_distance.y)

	var max_height = dist_y + v_jump_offset

	if target_node.y > controller.position.y:
		max_height = v_jump_offset

	var v0y = -sqrt(max_height * 2 * gravity)

	var t_total
	if target_node.y > controller.position.y:
		t_total = (-v0y + sqrt(v0y * v0y - 2 * -gravity * dist_y)) / gravity #TODO Doesn't work. Probably not important but I'd be good to fix
	else:
		t_total = (-v0y + sqrt(v0y * v0y - 2 * -gravity * -dist_y)) / gravity

	var dist_x = target_node.x - controller.position.x
	dist_x = clamp(dist_x, -jump_distance.x, jump_distance.x)

	var v0x = dist_x / t_total

	print("dist_y: ", dist_y)
	print("dist_x: ", dist_x)
	print("v0y: ", v0y)
	print("t_total: ", t_total)
	print("v0x: ", v0x)

	controller.velocity = Vector2(v0x, v0y)


func tick(delta):
	controller.velocity.y += gravity * delta
	controller.move_and_slide()

	if not controller.check_is_on_floor():
		on_change_state.emit(fall_state, {})


func check_conditions(vars) -> bool:
	return controller.check_is_on_floor()
