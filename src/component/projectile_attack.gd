class_name ProjectileAttack
extends Component

@export var projectile: Node2D = null
@export var projectile_spawnpoint: Node2D = null
@export var aim_to_movement: bool = true
@export var aim_to_target: bool = false
@export var cooldown: float = 1

var movement: MovementVector = null
var aim: Vector2 = Vector2(1, 0)
var _wait: float = 0
var _targeting: Targeting = null

var targeting: Targeting:
	get:
		if not _targeting:
			_targeting = Component.get_component(entity, Targeting)
		return _targeting

var entity2d: Node2D:
	get: return entity as Node2D

func _ready() -> void:
	assert(entity is Node2D)
	assert(Component.get_component(projectile, Projectile))
	assert(not aim_to_target or (aim_to_target and get_component(entity, Targeting)))
	
	projectile.get_parent().remove_child(projectile)
	movement = Component.get_component(entity, MovementVector)

func _physics_process(delta: float) -> void:
	if aim_to_target and targeting.target:
		var dif := targeting.target.global_position - entity2d.global_position
		dif.normalized()
		aim = dif
	elif aim_to_movement:
		if movement.movement_vector.x != 0:
			aim.x = signf(movement.movement_vector.x)
	if _wait > 0:
		_wait -= delta
		if _wait < 0:
			_wait = 0

func attack() -> void:
	if _wait > 0: return
	_wait = cooldown
	var new_proj_node := projectile.duplicate() as Node2D
	get_tree().root.add_child(new_proj_node)
	new_proj_node.global_position = projectile_spawnpoint.global_position
	var new_proj := Component.get_component(new_proj_node, Projectile) as Projectile
	new_proj.projectile_owner = entity
	
	var proj_move := Component.get_component(new_proj_node, MovementVector) as MovementVector
	proj_move.movement_vector = aim
	
	new_proj_node.reset_physics_interpolation()
