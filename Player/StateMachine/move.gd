extends State


@export_category("Provided")
@export var animator: AnimatableBody3D
@export var controller: CharacterBody3D

@export_category("Main")
@export var SPEED = 5.0

@export_category("DEBUG")


@onready var dash: Node = $"../DashState"
@onready var run: Node = $"../RunState"
@onready var attack: Node = $"../AttackState"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not controller.is_on_floor():
		controller.velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (controller.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		controller.velocity.x = direction.x * SPEED
		controller.velocity.z = direction.z * SPEED
	else:
		controller.velocity.x = move_toward(controller.velocity.x, 0, SPEED)
		controller.velocity.z = move_toward(controller.velocity.z, 0, SPEED)

	controller.move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("dash") and controller.is_on_floor() and abs(controller.velocity.x) + abs(controller.velocity.z) > 0 :
		exit_state(dash, event)
	if event.is_action_pressed("run") and controller.is_on_floor() and abs(controller.velocity.x) + abs(controller.velocity.z) > 0:
		exit_state(run, event)
	if event.is_action_pressed("melee_primary") or event.is_action_pressed("ranged_primary") \
		# or event.is_action_pressed("melee_secondary") or event.is_action_pressed("ranged_secondary") \
		:
			
		exit_state(attack, event)
