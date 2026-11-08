class_name ContactDamage
extends Node

signal on_damage_given(dmg: float)

@export var actor: Actor = null
@export var hitbox: Area2D = null
@export var damage: float = 1

func _ready() -> void:
	hitbox.body_entered.connect(_hitbox_entered)

func _hitbox_entered(other: Node2D):
	var damageable := Damageable.get_component(other)
	if not damageable: return
	damageable.damage(damage)
	on_damage_given.emit(damage)
