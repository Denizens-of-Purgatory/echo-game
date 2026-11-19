class_name GroundJump
extends Component

signal on_jump_begin()

## how quickly the actor is launched upwards immedialely when jumping
@export var jump_power: float = 450

## how long the jump is sustained for when holding the jump button. From 0 to 1,
## where 1 means the jump is sustained indefinitely, and 0 means it is not 
## sustained at all. Jump sustain is treated as a constant upward force 
## with magnitude relative to gravity on the actor. jump sustain force is 
## as long as jump input is recieved until the jump reaches it's peak, or a 
## collision gets in the way
@export_range(0, 1) var jump_sustain: float = 0.5

## the amount of times the actor can jump after already being in the air, 
## before touching the ground. 1 would be a double jump, 2 would be a triple 
## jump, and so on
@export var max_air_jumps: int = 1

var ground_detection: GroundDetection = null
var ground_movement: GroundMovement = null
var ladder_user: LadderUser = null
var dash: Dash = null

## how many air jumps the actor has already done since last touching ground
var _air_jumps_used: int = 0 
## if the actor will jump immediately after hitting the ground
var _jump_queued: bool = false
## true if jump input is recieved
var _is_jumping: bool = false
## if jump input received in previous step
var _was_jumping: bool = false

var actor: RigidBody2D:
	get: return entity as RigidBody2D

#### ------------------- SIGNAL RECEIVERS --------------------------------------

func _ready() -> void:
	
	# get required components
	ground_detection = Component.get_component(entity, GroundDetection)
	ground_movement = Component.get_component(entity, GroundMovement)
	ladder_user = Component.get_component(entity, LadderUser)
	dash = Component.get_component(entity, Dash)
	
	assert(ground_detection)
	assert(entity is RigidBody2D)
	
	if not actor.on_integrate_forces.is_connected(_actor_integrate_forces):
		actor.on_integrate_forces.connect(_actor_integrate_forces) 
		ground_detection.on_ground_enter.connect(_reset_air_jumps)
		if ladder_user: ladder_user.on_climb_start.connect(_reset_air_jumps)

func _actor_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	_handle_jump_state(state)
	
#### ------------------- PRIVATE IMPLEMENTATION --------------------------------

func _handle_jump_state(state: PhysicsDirectBodyState2D) -> void:
	# make actor jump if jump input received and on ground (or climbing)
	if (
		(ground_detection.is_on_ground() or (ladder_user and ladder_user.is_climbing())) or 
		(_air_jumps_used < max_air_jumps and is_falling(state))
	):
		if (_is_jumping && !_was_jumping) or _jump_queued:
			if not (ground_detection.is_on_ground() or (ladder_user and ladder_user.is_climbing())):
				_air_jumps_used += 1
			if ladder_user and ladder_user.is_climbing():
				ladder_user.stop_climbing()
			_handle_jump(state)
	elif _is_jumping:
		_handle_jump_sustain(state)
	
	# reset flags
	if !_is_jumping: _jump_queued = false
	_was_jumping = _is_jumping
	_is_jumping = false

func _handle_jump(state: PhysicsDirectBodyState2D) -> void:
	# ignore jump if mid-dash
	if dash and dash.is_dashing(): return
	
	# get relative axes
	var up_axis := -state.total_gravity.normalized()
	var fwd_axis := -up_axis.orthogonal()
	var up_vel := jump_power
	var fwd_vel := fwd_axis * state.linear_velocity
	
	# apply velocity relative to local axes
	ground_detection.set_ungrounded()
	state.linear_velocity = fwd_axis * fwd_vel + up_axis * up_vel
	_jump_queued = false
	on_jump_begin.emit()

func _handle_jump_sustain(state: PhysicsDirectBodyState2D) -> void:
	# ignore jump sustain if mid-dash
	if dash and dash.is_dashing(): return
	
	var grav := state.total_gravity
	var up_axis := -grav.normalized()
	var up_vel := up_axis.dot(actor.linear_velocity)
	
	# only jump sustain if still moving upward from initial jump velocity
	if up_vel > 0:
		state.linear_velocity += -grav * jump_sustain * state.step

func _reset_air_jumps() -> void:
	_air_jumps_used = 0

#### -------------------- PUBLIC IMPLEMENTATION --------------------------------

func is_falling(state: PhysicsDirectBodyState2D) -> bool:
	if ground_detection.has_ground_contact():
		return false
	var up_axis := -actor.get_gravity().normalized()
	var up_vel := up_axis.dot(state.linear_velocity)
	return up_vel <= 0
	
## make the actor jump if they're able to
func jump():
	_is_jumping = true
	if !_was_jumping:
		_jump_queued = true
