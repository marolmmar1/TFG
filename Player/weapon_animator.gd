@tool

extends AnimationPlayer

const ANIM_DICT = {
	Weapon.WeaponAnimType.SWEEP: ["SweepAttack", "SweepAttack", "SweepAttack"]
}

#FIXME me da la sennsacion de que esto es complejidad innecesria. Por un lado, el nodo de animaciónno debería encargarse de cosas como los combos y tal, eso es cosa del 
# estado. Por otro lado, quiero que la animación marque el ritmo de estos eventos. Pero aqui hay demasiada comunicacion por señales para un mismo proceso. Lo natural se me 
# haría que el animator fuera hijo del estado, pero con la estructura actual no se puede. No sé, revisar.
signal on_attack_anim_free
signal on_attack_anim_finished

@export_category("Main")
@export var weapon_blend: float = 0.0:
	set(value):
		if not anim_length:
			_ready()
		weapon_blend = value
		weapon_anim_tree["parameters/TimeSeek/seek_request"] = value * anim_length

@export var weapon: Weapon
@export var weapon_main_anim: String

var weapon_anim_tree: AnimationTree
var anim_length: float

func attack_anim_set_free() -> void:
	on_attack_anim_free.emit()

func attack_anim_set_finished() -> void:
	on_attack_anim_finished.emit()

func _ready() -> void:
	weapon_anim_tree = weapon.get_node("AnimationTree")
	anim_length = weapon_anim_tree.get_animation(weapon_main_anim).length

func start_weapon_anim(_weapon: Weapon, combo_count: int) -> void:
	weapon = _weapon

	var anim_name = ANIM_DICT[weapon.weapon_anim_type][combo_count - 1]
	stop()
	play(anim_name)

func perform_attack() -> void:
	weapon.perform_primary()
