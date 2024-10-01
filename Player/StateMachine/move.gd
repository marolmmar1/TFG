class_name MoveState

extends State


@export_category("Provided")
@export var animator: AnimatableBody3D
@export var controller: CharacterBody3D

@export_category("Main")
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@export_category("DEBUG")




# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not controller.is_on_floor():
		controller.velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and controller.is_on_floor():
		controller.velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		controller.velocity.x = direction.x * SPEED
		controller.velocity.z = direction.z * SPEED
	else:
		controller.velocity.x = move_toward(controller.velocity.x, 0, SPEED)
		controller.velocity.z = move_toward(controller.velocity.z, 0, SPEED)

	controller.move_and_slide()
