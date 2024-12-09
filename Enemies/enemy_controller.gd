class_name EnemyController
extends CharacterBody3D

@export_category("Provided")
@export var animator: AnimationPlayer

@export_category("Main")
@export var camera_shake := 0.1
@export var camera_shake_duration := 0.05

func _ready():
	self.add_to_group("Targetables")
	EventSystem.main_game_bus.on_enemy_enter.emit(self)

	var damageable = self.get_node("Damageable") as Damageable
	damageable.on_damaged.connect(take_damage)
	
func take_damage(source_pos: Vector3, weapon_source: Weapon):

	EventSystem.main_game_bus.on_camera_shake.emit(camera_shake, camera_shake_duration)
	$AudioPlayer.play_audio()

	animator.play("Hitted")

	look_at(Vector3(source_pos.x, global_position.y, source_pos.z), Vector3.UP)
	velocity = (global_position - source_pos).normalized() * Vector3(weapon_source.knockback, 0, weapon_source.knockback)
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity -= velocity * 5.0 * delta