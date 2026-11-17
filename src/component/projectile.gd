class_name Projectile
extends Component

signal on_hit(other: Node2D)
signal on_hit_damageable(damageable: Damageable)

@export var collision_area: Area2D = null
@export var collision_raycast: RayCast2D = null
@export var destroy_on_collide: bool = true
@export var max_lifetime: float = 5
@export var speed: float = 500

var movement: MovementVector = null
var lifetime: float = 0
var _projectile_owner: Node = null
var _last_position: Vector2 = Vector2.ZERO

var projectile_owner: Node2D:
	get: return projectile_owner
	set(val):
		if (val == _projectile_owner): return
		_projectile_owner = val
		if collision_raycast: 
			collision_raycast.add_exception(val)
		var ct_dam := Component.get_component(entity, ContactDamage) as ContactDamage
		if ct_dam:
			ct_dam.ignore_collisions_with(val)

var entity2d: Node2D:
	get: return entity as Node2D

func _integrate_position(delta: float) -> void:
	var velocity = movement.movement_vector * speed
	_last_position = entity2d.global_position
	entity2d.global_position += velocity * delta
	
	if collision_raycast:
		collision_raycast.global_position = _last_position
		collision_raycast.target_position = collision_raycast.to_local(entity2d.global_position)
		collision_raycast.force_raycast_update()
		if collision_raycast.is_colliding():
			_hit_other(collision_raycast.get_collider(), true)

func _hit_other(other: Node2D, pass_forward: bool = false) -> void:
	if other == _projectile_owner or other == entity:
		return
	var damageabe := Damageable.get_component(other, Damageable)
	on_hit.emit(other)
	if damageabe:
		on_hit_damageable.emit(damageabe)
		if pass_forward:
			var damager := Component.get_component(entity, ContactDamage) as ContactDamage
			if damager:
				damager.hit(damageabe)
	
	if destroy_on_collide:
		entity2d.queue_free()

func _ready() -> void:
	movement = Component.get_component(entity, MovementVector)
	assert(movement)
	assert(entity is Node2D)
	_last_position = entity2d.global_position
	
	if collision_raycast:
		collision_raycast.enabled = false
		if (_projectile_owner): collision_raycast.add_exception(_projectile_owner)
	
	if collision_area:
		collision_area.body_entered.connect(_hit_other)

func _physics_process(delta: float) -> void:
	_integrate_position(delta)
	lifetime += delta
	if lifetime > max_lifetime:
		entity2d.queue_free()
