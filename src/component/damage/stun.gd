class_name Stun
extends Component

signal on_stunned()
signal on_stun_end()

var _stun_time: float = 0

var is_stunned: bool:
	get(): return _stun_time > 0

func _physics_process(delta: float) -> void:
	if is_stunned:
		_stun_time -= delta
		if not is_stunned:
			_stun_time = 0
			on_stun_end.emit()

func stun(time: float = 1):
	if not is_stunned:
		on_stunned.emit()
	_stun_time = maxf(time, _stun_time)
