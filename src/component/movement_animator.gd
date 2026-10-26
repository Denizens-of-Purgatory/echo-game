class_name MovementAnimator
extends Node

@export var actor: RigidBody2D = null
@export var sprite: AnimatedSprite2D = null
@export var movement: Movement = null
@export var ground_detection: GroundDetection = null

@export var auto_flip: bool = true
@export var anim_idle: StringName = "Idle"
@export var anim_run: StringName = "Run"
@export var anim_trans_run_idle: StringName = "RunToIdle"
@export var anim_jump_rise: StringName = "JumpRise"
@export var anim_fall: StringName = "JumpMid"
@export var anim_trans_fall_idle: StringName = "Land"

var _anim_locked: bool = false

func _ready() -> void:
	sprite.play()
	sprite.animation_finished.connect(_on_anim_finish)
	sprite.animation_looped.connect(_on_anim_finish)

func _process(_delta: float) -> void:
	
	# flip the sprite horizontally based on input
	if auto_flip and not _anim_locked:
		if movement.move_vector.x < 0:
			sprite.scale.x = -absf(sprite.scale.x)
		elif movement.move_vector.x > 0:
			sprite.scale.x = absf(sprite.scale.x)
	
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
