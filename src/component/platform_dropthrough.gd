class_name PlatformDropthrough
extends Node

@export var actor: RigidBody2D = null
@export var ground_detection: GroundDetection = null
@export_flags_2d_physics var platform_layers: int = 2

var _overlapper: Area2D = null
var _drop_time: float = 0
var _exceptions: Array[PhysicsBody2D] = []

func _ready() -> void:
	# create a new collision area with the same collision as the actor to 
	# track when platforms are no longer being overlapped after the 
	# collision drop starts
	var shape := CollisionShape2D.new()
	shape.shape = actor.shape_owner_get_shape(actor.get_shape_owners()[0], 0)
	_overlapper = Area2D.new()
	_overlapper.add_child(shape)
	_overlapper.collision_layer = 0
	_overlapper.collision_mask = platform_layers
	actor.add_child.call_deferred(_overlapper)

func _physics_process(delta: float) -> void:
	# reset collisions after timeout
	if _drop_time > 0:
		_drop_time -= delta
		if _drop_time <= 0:
			_reset_collision()
			_drop_time = 0
	
	# check each excluded platform and if it's no longer overlapping, stop 
	# ignoring collisions with it
	elif not _exceptions.is_empty():
		var overlaps := _overlapper.get_overlapping_bodies()
		for i in range(_exceptions.size() - 1, -1, -1):
			var ex := _exceptions[i]
			if ex not in overlaps:
				actor.remove_collision_exception_with(ex)
				_exceptions.remove_at(i)

func _reset_collision() -> void:
	var overlaps := _overlapper.get_overlapping_bodies()
	for overlap in overlaps:
		_exceptions.push_back(overlap)
		actor.add_collision_exception_with(overlap)
	actor.collision_mask |= platform_layers

## Drop collision with platform layers for specified amount of time in seconds
func drop_collision(time: float = 0.2) -> void:
	if _drop_time > 0: return
	actor.sleeping = false
	actor.collision_mask &= ~platform_layers
	_drop_time = time
