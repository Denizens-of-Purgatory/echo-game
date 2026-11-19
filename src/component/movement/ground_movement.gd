class_name GroundMovement
extends Movement

## the axis that ground movement forces will be applied along
enum MoveAxis {
	GroundNormal,
	GravityNormal
}

## defines when the actor should have velocities corrected to resist slipping 
## slowly down slopes
enum SlopeSlipResistMode {
	Never,
	WhenMoving,
	WhenStill,
	Always
}

## the axis that ground movement forces will be applied along, whether it will
## be perpendicular to the ground normal, or perpendicular to the actor gravity
@export var move_axis: MoveAxis = MoveAxis.GroundNormal

## when should the actor have velocities corrected to prevent slipping down 
## slopes. Default is "WhenMoving" when use native friction is on, otherwise
## "Always" is recommended for when use native friction is off
@export var slope_resist_mode: SlopeSlipResistMode = SlopeSlipResistMode.WhenMoving

## if true, friction is calculated by the physics engine instead of using our 
## custom implementation. May work better in cases where the character is 
## walking on a lot of different dynamic physics surfaces
@export var use_native_friction: bool = true

## the ground friction damping factor applied to the actor at each step while 
## on the ground, 1 means the actor will stop immediately, while 0 means they 
## will slip and slide around like on ice
@export_range(0, 1) var ground_friction: float = 0.5

## component to detect whether actor is on ground or not
var ground_detection: GroundDetection = null
## component that allows the actor to be stunned
var stun: Stun = null
## component which allows actor to drop through platform collisions
var dropthrough: PlatformDropthrough = null
## component that grants the ability to climb ladders which affects movement
var ladder_user: LadderUser = null
## component that grants an actor the dash ability which can affect movement
var dash: Dash = null
## component that controls whether the actor is slippery or not
var slippery: Slippery = null

var movement_vector: MovementVector = null

## the linear velocity of the actor in the previous step
var _prev_velocity: Vector2 = Vector2.ZERO
## the original native friction of the rigidbody
var _native_friction_factor: float = -1
## the original native friction 'rough' property value of the rigidbody
var _native_friction_rough: bool = false
## track when ground friction is explicitly applied to the body
var _ground_friction_applied: bool = false

#### ------------------- GETTERS/SETTERS ---------------------------------------

var actor: RigidbodyForceIntegrator:
	get: return entity as RigidbodyForceIntegrator

func is_moving() -> bool: return absf(movement_vector.movement_vector.x) >= 0.1

#### ------------------- SIGNAL RECEIVERS --------------------------------------

func _ready() -> void:
	
	if !use_native_friction:
		# require frictionless physics material for custom friction
		if actor.physics_material_override == null or actor.physics_material_override.friction > 0:
			push_warning(
				"no frictionless physics_material override detected, please ensure " +
				"the friction is 0 for the rigidbody, when using non-native friction "
			)
	else:
		if actor.physics_material_override == null:
			push_warning("no native physics material, creating new one..")
			actor.physics_material_override = PhysicsMaterial.new()
		_native_friction_factor = actor.physics_material_override.friction
		_native_friction_rough = actor.physics_material_override.rough

	movement_vector = Component.get_component(entity, MovementVector)
	ground_detection = Component.get_component(actor, GroundDetection)
	stun = Component.get_component(entity, Stun)
	dropthrough = Component.get_component(entity, PlatformDropthrough)
	ladder_user = Component.get_component(entity, LadderUser)
	dash = Component.get_component(entity, Dash)
	slippery = Component.get_component(entity, Slippery)
	
	assert(entity is RigidbodyForceIntegrator)
	assert(movement_vector)
	assert(ground_detection)

	# attach signals
	if not actor.on_integrate_forces.is_connected(_actor_integrate_forces):
		actor.on_integrate_forces.connect(_actor_integrate_forces) 

func _actor_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not enabled: return
	
	if stun and stun.is_stunned:
		movement_vector.movement_vector = Vector2.ZERO

	if ground_detection.is_on_ground():
		if not ground_detection._was_on_ground:
			_handle_ground_impact_velocity_correction(state)
		if ground_detection.has_ground_contact():
			match slope_resist_mode:
				SlopeSlipResistMode.Always: _handle_resist_slope_sliding(state)
				SlopeSlipResistMode.WhenMoving: 
					if is_moving(): _handle_resist_slope_sliding(state)
				SlopeSlipResistMode.WhenStill: 
					if !is_moving(): _handle_resist_slope_sliding(state)
	
	_handle_ground_movement(state)
	
	# remove friction unless it was explicitly applied this frame
	if use_native_friction:
		if _ground_friction_applied: _ground_friction_applied = false
		elif actor.physics_material_override.friction != 0:
			actor.physics_material_override.friction = 0
			actor.physics_material_override.rough = false
	
	# store previous velocity for next frame
	_prev_velocity = state.linear_velocity

#### ------------------- PRIVATE IMPLEMENTATION --------------------------------

## calculate velocity relative to body's local axes, maintaining the previous 
## frame's forward velocity
func _handle_ground_impact_velocity_correction(state: PhysicsDirectBodyState2D) -> void:
	var up_axis := -state.total_gravity.normalized()
	var fwd_axis := -up_axis.orthogonal()
	var up_vel := up_axis.dot(state.linear_velocity)
	var fwd_vel := fwd_axis.dot(_prev_velocity)
	state.linear_velocity = up_axis * up_vel + fwd_axis * fwd_vel

func _handle_resist_slope_sliding(state: PhysicsDirectBodyState2D) -> void:
	var ground_axis := -ground_detection._last_ground_norm.orthogonal()
	var up_axis := ground_axis.orthogonal()
	var ground_vel := ground_axis.dot(state.linear_velocity)
	var up_vel := up_axis.dot(state.linear_velocity)

	var down := state.total_gravity
	var theta := down.angle_to(ground_axis)
	var slide_mag := cos(theta) * state.total_gravity.length()
	var fall_mag := sin(theta) * state.total_gravity.length()
	
	ground_vel += slide_mag * -state.step
	up_vel += fall_mag * -state.step
	state.linear_velocity = ground_axis * ground_vel + up_axis * up_vel

## apply horizontal movement forces to the body
func _handle_ground_movement(state: PhysicsDirectBodyState2D) -> void:
	# if no movement input, apply friction and return
	if !is_moving():
		_apply_ground_friction(state)
		return 
	
	# calculate the relative velocity
	var up_axis := -actor.get_gravity().normalized()
	if move_axis == MoveAxis.GroundNormal and ground_detection.is_on_ground():
		up_axis = ground_detection._last_ground_norm
	var fwd_axis := -up_axis.orthogonal()
	var up_vel := up_axis.dot(state.linear_velocity)
	var fwd_vel := fwd_axis.dot(state.linear_velocity)
	
	# calculate desired motion parameters
	var targ_vel := max_speed * clampf(movement_vector.movement_vector.x, -1, 1)
	var acceleration := max_speed * acceleration_factor
	
	# if speed is higher than max speedNod
	if absf(fwd_vel) > absf(targ_vel):
		var dif_vel_x := targ_vel - fwd_vel
		var acc_x: float = minf(acceleration, absf(dif_vel_x)) * signf(dif_vel_x) * state.step
		if ground_detection.is_on_ground():
			if signf(fwd_vel) != signf(targ_vel):
				fwd_vel = 0
			else:
				fwd_vel += acc_x
		elif signf(acc_x) != signf(fwd_vel):
			fwd_vel += acc_x
		_apply_ground_friction(state)
	
	# if speed needs to be increased
	else: 
		# calculate total horizontal acceleration for this step
		var acc_x: float = acceleration * movement_vector.movement_vector.x * state.step
#		
		# if ground friction helps accelerate toward target velocity, apply friction
		if signf(fwd_vel + acc_x) != signf(targ_vel):
			_apply_ground_friction(state)
			fwd_vel = fwd_axis.dot(state.linear_velocity)
#		
		# if acceleration causes actor to exceed speed limit, just set the velocity to target vel
		if absf(fwd_vel + acc_x) >= absf(targ_vel):
			fwd_vel = targ_vel
		
		# accelerate actor if the acceleration won't cause it to go over the speed limit
		else: fwd_vel += acc_x
	
	# apply the relative velocity changes to the actor
	state.linear_velocity = fwd_axis * fwd_vel + up_axis * up_vel

## applies ground friction to the body
func _apply_ground_friction(state: PhysicsDirectBodyState2D) -> void:
	if slippery and slippery.is_slippery: return
	if ground_detection.is_on_ground() and ground_detection.has_ground_contact():
		if use_native_friction:
			if actor.physics_material_override.friction != _native_friction_factor:
				actor.physics_material_override.friction = _native_friction_factor
				actor.physics_material_override.rough = _native_friction_rough
		else:
			state.linear_velocity *= pow(1 - ground_friction, state.step * 50)
		_ground_friction_applied = true

#### ------------------- PUBLIC IMPLEMENTATION ---------------------------------

func move(move_dir: Vector2, clamp_to_one: bool = true) -> void:
	if ladder_user:
		ladder_user.climb(move_dir.y)
	if dropthrough:
		if move_dir.y > 0 and ground_detection.has_ground_contact():
			dropthrough.drop_collision()
	move_horizontal(move_dir.x, clamp_to_one)
	movement_vector.movement_vector.y = movement_vector.movement_vector.y

## move the player in the specified direction. A move_dir of 1 is right, left 
## is -1. Absolute value less than 1 will move the actor slower than their 
## max_speed. Absolute values higher than 1 will only move the actor faster
## than their max speed if clamp_to_one is set to false
func move_horizontal(move_dir: float, clamp_to_one: bool = true) -> void:
	if clamp_to_one: movement_vector.movement_vector.x = clampf(move_dir, -1, 1)
	else: movement_vector.movement_vector.x = move_dir

## move the actor to the right according to speed properties
func move_right() -> void: move_horizontal(1)

## move the actor to the left according to speed properties
func move_left() -> void: move_horizontal(-1)
