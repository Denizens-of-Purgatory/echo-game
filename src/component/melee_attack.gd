class_name MeleeAttack
extends Component

@export var attack_container: Node2D = null
@export var attack_area: Area2D = null
@export var attack_animation: StringName = "attack"
@export var attack_damage: float = 5
@export var attack_time: float = 0.4
@export var cooldown: float = 0.4
@export var flip_with_movement: bool = true

var _movement: GroundMovement = null
var _attack_delta: float = -1
var _attack_wait: float = 0
var _attacked_nodes: Array[Node2D] = []

var is_attacking: bool:
	get: return _attack_delta >= 0

func _handle_attacking(delta: float) -> void:
	_attack_delta += delta
	
	if _attack_delta >= attack_time:
		attack_area.get_parent().remove_child(attack_area)
		_attack_delta = -1
		_attack_wait = cooldown
		_attacked_nodes.clear()

func _attack_overlap(other: Node2D):
	# don't damage self
	if entity == other: return
	
	var damageable := Damageable.get_component(other)
	if damageable:
		if other in _attacked_nodes: return
		damageable.damage(attack_damage)

func _ready() -> void:
	attack_area.get_parent().remove_child(attack_area)
	attack_area.body_entered.connect(_attack_overlap)

func _physics_process(delta: float) -> void:
	if _attack_delta >= 0:
		_handle_attacking(delta)
	else:
		if _attack_wait > 0:
			_attack_wait -= delta
			if _attack_wait < 0:
				_attack_wait = 0
		if flip_with_movement:
			if not _movement:
				_movement = get_component(entity, GroundMovement)
			if _movement:
				if absf(signf(_movement.move_vector.x) - signf(attack_container.position.x)) > 1:
					attack_container.position.x *= -1

func begin_attack() -> void:
	if is_attacking or _attack_wait > 0: return
	attack_area.position = Vector2.ZERO
	attack_container.add_child(attack_area)
	_attack_delta = 0
