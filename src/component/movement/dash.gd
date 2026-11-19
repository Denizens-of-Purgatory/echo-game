class_name Dash
extends Component

signal on_dash_start()
signal on_dash_stop()

@export var movement: Movement = null

@export var dash_time: float = 0.2
@export var dash_speed_multiplier: float = 2

## whether or not the dash ability can be initiated while in the air
@export var air_dash_allowed: bool = true

## how many dashes the actore can do before it has to cool down
@export var max_consecutive_dashes: int = 1

## time in seconds before the ability can be used after dashing
@export var dash_cooldown: float = 0.5

## dash time remaining before dash is finished
var _dashing: float = 0
var _dash_dir: float = 0
var _dash_cooldown_time: float = 0
var _consecutive_dashes_used: int = 0
var _dash_queued: bool = false

var actor: RigidbodyForceIntegrator:
	get: return entity as RigidbodyForceIntegrator

func _ready() -> void:
	actor.on_integrate_forces.connect(_actor_integrate_forces)

func _actor_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _dashing > 0:
		var speed := movement.max_speed * dash_speed_multiplier
		state.linear_velocity.y = 0
		state.linear_velocity.x = speed * _dash_dir

func _physics_process(delta: float) -> void:
	if _dashing > 0:
		_dashing -= delta
		if _dashing <= 0:
			on_dash_stop.emit()
			actor.linear_velocity.x /= dash_speed_multiplier
			_dash_cooldown_time = dash_cooldown
			_dashing = 0
	elif _dash_queued and can_dash():
		actor.linear_velocity.y = 0
		_dashing = dash_time
		_consecutive_dashes_used += 1
		on_dash_start.emit()
	
	# handle dash cooldown
	if _dash_cooldown_time > 0 and not is_dashing():
		_dash_cooldown_time -= delta
		if _dash_cooldown_time <= 0:
			_consecutive_dashes_used = 0
			_dash_cooldown_time = 0
	
	_dash_queued = false

func can_dash() -> bool:
	return _dashing <= 0 and _consecutive_dashes_used < max_consecutive_dashes

func is_dashing() -> bool:
	return _dashing > 0

func dash(direction: float) -> void:
	_dash_dir = direction
	_dash_queued = true
