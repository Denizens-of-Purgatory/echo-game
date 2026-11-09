class_name LadderUser
extends Node

signal on_climb_start()
signal on_climb_end()

@export var actor: RigidbodyForceIntegrator = null
@export var detector: Area2D = null

## overlap area used to prevent the actor from getting off the ladder if they 
## are still overlapping a solid area that the ladder goes through
@export var overlapper: Area2D = null
@export var movement: Movement = null
@export var ground_detection: GroundDetection = null
@export var climb_speed_multiplier: float = 0.5

var _ladder_collision_exceptions: Array[PhysicsBody2D] = []
var _ladder_to_use: Ladder = null
var _climbing: bool = false
var _climb_dir: float = 0

func _ready() -> void:
	actor.on_integrate_forces.connect(_actor_integrate_forces)
	detector.area_entered.connect(_area_entered)
	detector.area_exited.connect(_area_exited)
	overlapper.body_exited.connect(_overlapper_body_exited)

func _area_entered(area: Area2D) -> void:
	if is_climbing(): return
	var ladder := Ladder.find(area)
	if ladder:
		_ladder_to_use = ladder

func _area_exited(area: Area2D) -> void:
	if is_climbing(): return
	if _ladder_to_use and area == _ladder_to_use.parent:
		_ladder_to_use = null

func _overlapper_body_exited(other: Node2D) -> void:
	if is_climbing(): return
	
	var index := _ladder_collision_exceptions.find(other)
	if index >= 0:
		actor.remove_collision_exception_with(other)
		_ladder_collision_exceptions.remove_at(index)

func _begin_climbing() -> void:
	if _climbing or not _ladder_to_use: return
	if _climb_dir < 0 and _ladder_to_use.top_y() > actor.global_position.y:
		return
	if _climb_dir > 0 and _ladder_to_use.bottom_y() < actor.global_position.y + 32:
		return
	_climbing = true
	on_climb_start.emit()
	for collider in _ladder_to_use.ignore_colliders:
		_ladder_collision_exceptions.push_back(collider)
		actor.add_collision_exception_with(collider)

func _actor_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if is_climbing():
		_handle_climbing(state)

func _handle_climbing(state: PhysicsDirectBodyState2D) -> void:
	actor.global_position.x = _ladder_to_use.parent.global_position.x
	var speed := movement.max_speed * climb_speed_multiplier
	state.linear_velocity.x = 0
	state.linear_velocity.y = _climb_dir * speed
	
	if _climb_dir < 0:
		if _ladder_to_use.parent not in overlapper.get_overlapping_areas():
			state.linear_velocity.y = 0
			stop_climbing()

func is_climbing() -> bool:
	return _climbing

func stop_climbing() -> void:
	if not is_climbing(): return
	on_climb_end.emit()
	_climbing = false
	
	var overlapping := overlapper.get_overlapping_bodies()
	for i in range(_ladder_collision_exceptions.size() -1, -1, -1):
		var exception := _ladder_collision_exceptions[i]
		if exception in overlapping: continue
		
		actor.remove_collision_exception_with(exception)
		_ladder_collision_exceptions.remove_at(i)

func climb(dir: float = 0) -> void:
	_climb_dir = dir
	if is_climbing():
		if dir > 0 and ground_detection and ground_detection.has_ground_contact():
			stop_climbing()
	elif dir != 0:
		_begin_climbing()
