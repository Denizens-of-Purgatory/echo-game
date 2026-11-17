class_name ContactDamage
extends Component

signal on_damage_given(dmg: float)
signal on_damage_given_to(other: Node)

@export var hitbox: Area2D = null
@export var damage: float = 1

var _ignore_collisions: Array[Node2D] = []

func _ready() -> void:
	hitbox.body_entered.connect(_hitbox_entered)

func _hitbox_entered(other: Node2D) -> void:
	if other == entity: return
	if other in _ignore_collisions: return
	var damageable := Damageable.get_component(other)
	if damageable: 
		hit(damageable)

func hit(damageable: Damageable) -> void:
	damageable.damage(damage)
	on_damage_given.emit(damage)
	on_damage_given_to.emit(damageable.entity)

func ignore_collisions_with(other: Node2D) -> void:
	_ignore_collisions.push_back(other)
