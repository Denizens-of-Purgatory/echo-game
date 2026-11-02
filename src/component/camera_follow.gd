class_name CameraFollow
extends Node

@export var camera: Camera2D = null
@export var target: Actor = null

## How quickly the camera pans from 0 to 1, where 1 is instant
@export_range(0, 1) var follow_speed: float = 0.04

## How far away from the actor the camera pans
@export var look_distance_horizontal: float = 50
@export var look_distance_vertical: float = 75

var _curr_pos: Vector2 = Vector2.ZERO
var _prev_pos: Vector2 = Vector2.ZERO
var _fixed_timestep: float = 0
var _movement: Movement = null
var _last_move_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	_prev_pos = target.global_position
	_curr_pos = target.global_position
	camera.global_position = _curr_pos

func _physics_process(delta: float) -> void:
	_fixed_timestep = delta
	_prev_pos = camera.global_position
	_curr_pos = get_target_position()
	camera.global_position = (_prev_pos * (1-follow_speed) + _curr_pos * follow_speed)
	
func get_target_position() -> Vector2:
	if not _movement:
		_movement = Movement.get_from(target)
	
	var offset := Vector2.ZERO
	if _movement:
		if absf(_movement.move_vector.x) > 0.1:
			_last_move_dir.x = _movement.move_vector.x
		_last_move_dir.y = _movement.move_vector.y
		offset += Vector2(
			signf(_last_move_dir.x) * look_distance_horizontal,
			signf(_last_move_dir.y) * look_distance_vertical,
		)
	return target.global_position + offset
