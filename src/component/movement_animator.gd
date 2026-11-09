class_name MovementAnimator
extends Component

@export var sprite: AnimatedSprite2D = null

@export var auto_flip: bool = true
@export var anim_idle: StringName = "Idle"
@export var anim_run: StringName = "Run"
@export var anim_trans_run_idle: StringName = "RunToIdle"
@export var anim_jump_rise: StringName = "JumpRise"
@export var anim_fall: StringName = "JumpMid"
@export var anim_trans_fall_idle: StringName = "Land"
@export var anim_dash_end: StringName = "DashEnd"
@export var anim_dash_loop: StringName = "DashLoop"
@export var anim_climb_idle: StringName = "ClimbIdle"
@export var anim_climbing: StringName = "LadderClimb"

var input_controller: InputController = null
var movement: Movement = null
var stun: Stun = null
var death: Death = null
var ground_detection: GroundDetection = null
var ladder_user: LadderUser = null
var dash: Dash = null
var _anim_locked: bool = false

var actor: RigidBody2D:
	get: return entity as RigidBody2D

func _ready() -> void:
	assert(entity is RigidBody2D)
	
	input_controller = Component.get_component(entity, InputController)
	movement = Component.get_component(entity, GroundMovement)
	dash = Component.get_component(entity, Dash)
	death = Component.get_component(entity, Death)
	stun = Component.get_component(entity, Stun)
	ground_detection = Component.get_component(entity, GroundDetection)
	ladder_user = Component.get_component(entity, LadderUser)
	
	sprite.play()
	sprite.animation_finished.connect(_on_anim_finish)
	sprite.animation_looped.connect(_on_anim_finish)
	dash.on_dash_stop.connect(play_anim.bind(anim_dash_end, true, true))

func _process(_delta: float) -> void:
	
	if death and death.is_dead:
		play_anim("Die", true, true)
		return
	
	if stun and stun.is_stunned:
		play_anim("Knockback", true, true)
		return
	
	# flip the sprite horizontally based on input
	if auto_flip and not _anim_locked:
		var horizontal_orientation: float = 0
		if input_controller:
			horizontal_orientation = input_controller.last_horizontal_facing_direction
		elif movement:
			horizontal_orientation = movement.move_vector.x
		if horizontal_orientation < 0:
			sprite.scale.x = -absf(sprite.scale.x)
		elif horizontal_orientation > 0:
			sprite.scale.x = absf(sprite.scale.x)
	
	if dash and dash.is_dashing():
		play_anim(anim_dash_loop, false, true)
		return
	
	if ladder_user and ladder_user.is_climbing():
		if absf(ladder_user._climb_dir) < 0.1:
			play_anim(anim_climb_idle)
		else:
			play_anim(anim_climbing)
		return
	
	# play ground movement animations
	if ground_detection.is_on_ground():
		if sprite.animation == anim_fall:
			play_anim(anim_trans_fall_idle, true)
		else:
			var speed_threshold := movement.max_speed * 0.85
			if absf(movement.move_vector.x) > 0.25:
				play_anim(anim_run)
			elif absf(actor.linear_velocity.x) > speed_threshold:
				play_anim(anim_trans_run_idle, true)
			else:
				play_anim(anim_idle)
	
	# play air movement animations
	else:
		if absf(actor.linear_velocity.y < 0):
			play_anim(anim_jump_rise)
		else:
			play_anim(anim_fall)

func _on_anim_finish():
	_anim_locked = false

func play_anim(anim: StringName, lock: bool = false, interrupt: bool = false):
	if sprite.animation == anim:
		return
	if _anim_locked and not interrupt:
		return
	sprite.play(anim)
	_anim_locked = lock
