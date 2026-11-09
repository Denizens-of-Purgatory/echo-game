class_name Death
extends Node

signal on_die()
signal on_revive()

@export var actor: Node = null

var _is_dead: bool = false

func die() -> void:
	if not _is_dead:
		_is_dead = true
		on_die.emit()

func revive() -> void:
	if _is_dead:
		_is_dead = false
		on_revive.emit()
