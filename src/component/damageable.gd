class_name Damageable
extends Node

const FLAG: StringName = &"damageable"

static func get_component(node: Node) -> Damageable: 
	if node and node.has_meta(FLAG):
		return node.get_meta(FLAG, null)
	return null

signal on_damaged(damage: float)

## Just an overload for on_damaged but it emits no arguments
signal on_damaged_noarg()

@export var actor: Node = null
@export var death: Death = null

## Cannot receive damage while this is false
@export var enabled: bool = true

## If true, can still recieve damage when the death component reports dead
@export var enabled_while_dead: bool = false

func _enter_tree() -> void:
	actor.set_meta(FLAG, self)

func _exit_tree() -> void:
	actor.remove_meta(FLAG)

func damage(dmg: float):
	if not enabled: return
	if not enabled_while_dead and death and death.is_dead: return
	on_damaged.emit(dmg)
	on_damaged_noarg.emit()
