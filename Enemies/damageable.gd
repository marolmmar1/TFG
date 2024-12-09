class_name Damageable
extends Node

var guard := true

signal on_damaged(source_pos: Vector3, weapon_source: Weapon)

func get_damaged(source_pos: Vector3, weapon_source: Weapon):
    if guard:
        guard = false
        get_tree().create_timer(0.01).timeout.connect(func(): guard = true)

        on_damaged.emit(source_pos, weapon_source)
        