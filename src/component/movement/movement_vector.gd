class_name MovementVector
extends Component

@export var _movement_vector = Vector2.ZERO

var movement_vector: Vector2:
	get:
		if _movement_vector.length_squared() > 1:
			_movement_vector = _movement_vector.normalized()
		return _movement_vector
	set(val): 
		if val.length_squared() > 1:
			_movement_vector = val.normalized()
		_movement_vector = val

func _ready() -> void:
	_movement_vector = _movement_vector.normalized()
