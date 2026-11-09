class_name Death
extends Component

signal on_die()
signal on_revive()

var _is_dead: bool = false
var is_dead: bool: 
	get: return _is_dead

func die() -> void:
	if not _is_dead:
		_is_dead = true
		on_die.emit()

func revive() -> void:
	if _is_dead:
		_is_dead = false
		on_revive.emit()
