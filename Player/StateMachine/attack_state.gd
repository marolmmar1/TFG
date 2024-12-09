extends State

signal on_attack_anim_start(anim_type: Weapon.WeaponAnimType, combo_count: int)

@export_category("Provided")
@export var animator: AnimatableBody3D
@export var controller: CharacterBody3D

@export_category("Main")

@onready var move: Node = $"../MoveState"
@onready var run: Node = $"../RunState"

var combo_status := "closed" # closed -> ongoing -> open -> ongoing -> ...  -> open-> closed
var combo_count := 0

func enter_state(state, event=null) -> void:
	super(state)

	if combo_status == "closed":
		attack(event)

func attack(event):
	combo_count += 1
	print("combo count: ", combo_count)
	
	if event.is_action_pressed("melee_primary"):
		if combo_count > controller.melee_weapon.max_combo_count:
			return

		combo_status = "ongoing"
		on_attack_anim_start.emit(controller.melee_weapon, combo_count)

	# elif event.is_action_pressed("melee_secondary"):
	# 	controller.melee_weapon.perform_secondary(controller)

	elif event.is_action_pressed("ranged_primary"):
		if combo_count > controller.ranged_weapon.max_combo_count:
			return

		combo_status = "ongoing"
		on_attack_anim_start.emit(controller.ranged_weapon, combo_count)

	# elif event.is_action_pressed("ranged_secondary"):
	# 	controller.ranged_weapon.perform_secondary(controller)


func on_attack_anim_free() -> void:
	if combo_status == "closed":
		return
	combo_status = "open"

func on_attack_anim_finished() -> void:
	if combo_status == "ongoing":
		return
	combo_status = "closed"
	combo_count = 0
	if Input.is_action_pressed("run") and controller.is_on_floor() and abs(controller.velocity.x) + abs(controller.velocity.z) > 0:
		exit_state(run)
	else:
		exit_state(move)	

func _unhandled_input(event):
	if event.is_action_pressed("melee_primary") or event.is_action_pressed("ranged_primary") \
		# or event.is_action_released("melee_secondary") or event.is_action_released("ranged_secondary") \
		:
		if combo_status == "open":
			attack(event)
