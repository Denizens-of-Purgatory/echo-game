class_name GroundDetection
extends Node

signal on_ground_enter()
signal on_ground_exit()

## the actor that this script is referencing
@export var actor: RigidbodyForceIntegrator = null

## the amount of time it takes, after walking off a platform, for the actor to 
## realize its no longer on the ground
@export var max_coyote_time: float = 0.2

## the threshold at which a dot-product-slope is considered to be ground. 
## 1 is completely flat, 0 is a completely vertical wall, -1 is a ceiling
## (you should probably never set it below 0, and rarely set it even that low).
## NOTE that the slope falloff is sinusoidal, meaning a value of sqrt(2)/2 = 
## 0.71 represents a slope of 45 degrees, instead of what you might expect a  
## value of 0.5
@export_range(-1, 1) var slope_threshold: float = 0.71

## the resource ID of the actor in the physics direct space state
var _actor_rid: RID = RID()
## how long the actor has been off the ground for
var _hang_time: float = INF
## flag set if it grounded should return false
var _manual_unground: bool = false
## the ground normal in the previous frame
var _last_ground_norm: Vector2 = Vector2.ZERO
## whether the actor was on ground last frame or not
var _was_on_ground: bool = false
## the ground collider that the actor is currently colliding with (usually 
## should be CollisionObject2D but technically can be any Object type)
var _ground_collider: Object = null

#### ------------------- GETTERS/SETTERS ---------------------------------------

## return true if the actor is currently on the ground
func is_on_ground() -> bool:
	return _hang_time <= max_coyote_time

## return true if the actor was on the ground during the previous physics step
func was_on_ground() -> bool:
	return _was_on_ground

## return true if, during this physics step, the actor has an actual physics 
## contact with the ground
func has_ground_contact() -> bool:
	return _ground_collider != null

#### ------------------- SIGNAL RECEIVERS --------------------------------------

func _ready() -> void:
	# find actor if not referenced
	if actor == null:
		push_warning("actor not specified, finding actor..")
		var parent := get_parent()
		if parent is RigidBody2D:
			actor = parent
		else: push_error("GroundDetection must reference RegidBody2D as actor")
	
	# set up actor
	if actor is RigidbodyForceIntegrator:
		actor.on_integrate_forces.connect(_actor_integrate_forces)
	
		# assign component to actor if it's a rigid body controller
		if actor is CharacterRigidbody2D:
			if actor.ground_detection != null and actor.ground_detection != self:
				push_error("ERROR multiple GroundDetection found on ", actor)
			elif actor.ground_detection == null:
				actor.ground_detection = self
				print(self, " attached ground detection component!")
	
	# set required actor physics settings
	if !actor.contact_monitor: 
		push_warning("actor collision monitoring is off, turning on..")
		actor.contact_monitor = true
	if actor.max_contacts_reported < 4: 
		push_warning("actor max contacts is too low, raising..")
		actor.max_contacts_reported = 4
	
	_actor_rid = actor.get_rid()

func _physics_process(delta: float) -> void:
	# for rigidbody force integrators, this is already done in 
	# _integrate_forces, so we don't want to do it twice
	if actor is RigidbodyForceIntegrator: return
	
	# handle grounded calculations
	_was_on_ground = is_on_ground()
	if _manual_unground: _manual_unground = false
	else: _handle_ground_detection(PhysicsServer2D.body_get_direct_state(_actor_rid))
	_handle_ground_exit(delta)

func _actor_integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# handle grounded calculations
	_was_on_ground = is_on_ground()
	if _manual_unground: _manual_unground = false
	else: _handle_ground_detection(state)
	_handle_ground_exit(state.step)

#### ------------------- PRIVATE IMPLEMENTATION --------------------------------

## here we iterate through each physical contact and see of any of them can 
## be considered "ground"
func _handle_ground_detection(state: PhysicsDirectBodyState2D) -> void:
	var contact_ct := state.get_contact_count()
	_ground_collider = null
	for i in range(0, contact_ct):
		var obj: CollisionObject2D = state.get_contact_collider_object(i)
		if obj is CollisionObject2D:
			var col_intersect: int = actor.collision_mask & obj.collision_layer
			if col_intersect == 0:
				continue
		var local_norm := state.get_contact_local_normal(i)
		var up_axis := -state.total_gravity.normalized()
		var dot := up_axis.dot(local_norm)
		if dot >= slope_threshold:
			_ground_collider = obj
			_last_ground_norm = local_norm
			if !is_on_ground(): 
				on_ground_enter.emit()
			_hang_time = 0

func _handle_ground_exit(delta: float) -> void:
	var prev_on_ground := is_on_ground()
	_hang_time += delta
	if prev_on_ground && !is_on_ground():
		on_ground_exit.emit()

#### ------------------- PUBLIC IMPLEMENTATION ---------------------------------

## force the actor to be considered non-grounded immediately. This should be 
## called for instance when the actor is teleported, or boosted upward. If it is
## not called, the actor will still be considered on the ground for a small 
## amount of time (because of coyote time), and will experience ground friction
## and still be able to jump even if they are floating in the air.
func set_ungrounded() -> void:
	_manual_unground = true
	if is_on_ground():
		on_ground_exit.emit()
		_hang_time = max_coyote_time + 0.01
