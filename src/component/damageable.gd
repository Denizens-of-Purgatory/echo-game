class_name Damageable
extends Node

static func find(actor: Node) -> Damageable:
	for child in actor.get_children():
		if child is Damageable: return child as Damageable
	return null

signal on_damaged(damage: float)

## Just an overload for on_damaged but it emits no arguments
signal on_damaged_noarg()

@export var hurtbox: CollisionObject2D = null 
@export var death: Death = null

## Cannot receive damage while this is false
@export var enabled: bool = true

## If true, can still recieve damage when the death component reports dead
@export var enabled_while_dead: bool = false

func damage(dmg: float):
	if not enabled: return
	if not enabled_while_dead and death and death.is_dead: return
	on_damaged.emit(dmg)
	on_damaged_noarg.emit()
