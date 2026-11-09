class_name Movement
extends Component

## the max speed that the actor can accelerate to
@export var max_speed: float = 300

## how quickly the actor reaches their max speed, with a factor of 1, it takes
## one second, with a factor of 2 it takes 1/2 second, etc
@export var acceleration_factor: float = 5

var move_vector: Vector2 = Vector2.ZERO

## Instructs the movement component to move in the specified direction
func move(_move_dir: Vector2, _clamp_to_one: bool = true) -> void:
	push_error("Not implemented")
