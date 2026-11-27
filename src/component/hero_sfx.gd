class_name HeroSfx
extends Component

@export var footstep_stream: AudioStreamPlayer = null
@export var hurt_stream: AudioStreamPlayer = null
@export var death_stream: AudioStreamPlayer = null
@export var jump_stream: AudioStreamPlayer = null
@export var dash_stream: AudioStreamPlayer = null
@export var footstep_interval: float = 0.5

var _playing_footsteps: bool = false
var _footstep_wait: float = 0
var _death_comp: Death = null

var death: Death:
	get:
		if not _death_comp:
			_death_comp = Component.get_component(entity, Death)
		return _death_comp

func _ready() -> void:
	death.on_die.connect(play_death)
	
	var damageable := Component.get_component(entity, Damageable) as Damageable
	damageable.on_damaged_noarg.connect(play_hurt)

	var jump := Component.get_component(entity, GroundJump) as GroundJump
	jump.on_jump_begin.connect(play_jump)
	
	var dash := Component.get_component(entity, Dash) as Dash
	dash.on_dash_start.connect(play_dash)

func _process(delta: float) -> void:
	_handle_footsteps(delta)

func _handle_footsteps(delta: float) -> void:
	if not _playing_footsteps: return
	_footstep_wait -= delta
	if _footstep_wait <= 0:
		footstep_stream.play(0)
		_playing_footsteps = false
		_footstep_wait = footstep_interval

func play_footsteps() -> void:
	if death.is_dead: return
	_playing_footsteps = true

func play_jump() -> void:
	if death.is_dead: return
	jump_stream.play(0)

func play_dash() -> void:
	if death.is_dead: return
	dash_stream.play(0)

func play_death() -> void:
	death_stream.play(0)

func play_hurt() -> void:
	if death.is_dead: return
	hurt_stream.play()
