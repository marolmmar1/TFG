extends State


@export_category("Provided")
@export var animator: AnimatableBody3D
@export var controller: Player
@export var move: Node
@export var dash: Node

@export_category("Main")
@export var RUN_VELOCITY = 0.5
@export var RUN_COST = 4

@export_category("DEBUG")



func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		controller.velocity.x = direction.x * RUN_VELOCITY
		controller.velocity.z = direction.z * RUN_VELOCITY
	controller.get_tired(delta*RUN_COST)
	controller.move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("dash") and controller.is_on_floor() and  abs(controller.velocity.x)+ abs(controller.velocity.z)> 0:
		exit_state(dash, event)
	if controller.stamina==0 or event.is_action_released("run") or controller.is_on_floor()==false or  abs(controller.velocity.x)+ abs(controller.velocity.z)== 0:
		exit_state(move, event)