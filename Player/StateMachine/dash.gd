extends State


@export_category("Provided")
@export var animator: AnimatableBody3D
@export var controller: CharacterBody3D
@export var move: Node
@export var run: Node

@export_category("Main")
@export var DASH_VELOCITY = 3

@export_category("DEBUG")


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	controller.move_and_slide()
	

func enter_state(state, event = null):
	super(state)
	controller.velocity.x = controller.velocity.x * DASH_VELOCITY
	controller.velocity.z = controller.velocity.z * DASH_VELOCITY
	get_tree().create_timer(0.5).timeout.connect(handle_state)

func handle_state():
	if Input.is_action_pressed("run") and controller.is_on_floor() and  abs(controller.velocity.x)+ abs(controller.velocity.z)> 0:
		exit_state(run)
	else:
		exit_state(move)
