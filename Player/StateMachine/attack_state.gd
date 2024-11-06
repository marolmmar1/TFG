extends State

@export_category("Provided")
@export var animator: AnimatableBody3D
@export var controller: CharacterBody3D

@export_category("Main")



func enter_state(state, event=null) -> void:
	super(state)
	if event.is_action_pressed("melee_primary"):
		controller.melee_primary.perform_attack(controller)
	elif event.is_action_pressed("melee_secondary"):
		controller.melee_secondary.perform_attack(controller)
	elif event.is_action_pressed("ranged_primary"):
		controller.ranged_primary.perform_attack(controller)
	elif event.is_action_pressed("ranged_secondary"):
		controller.ranged_secondary.perform_attack(controller)
