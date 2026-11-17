extends Node2D


@export var fall_speed: float = 450.0
@export var warning_delay: float = 0.35
@export var max_fall_distance: float = 600.0

@onready var trigger: Area2D = $TriggerArea
@onready var moving_spike: Node2D = $MovingSpike
@onready var hitbox: Area2D = $MovingSpike/Hitbox
@onready var ground_ray: RayCast2D = get_node_or_null("%GroundRay") as RayCast2D

var activated: bool = false
var falling: bool = false
var start_y: float = 0.0

#
func _ready() -> void:
	if ground_ray == null:
		push_error("GroundRay not found in: " + str(get_path()))
		print_tree_pretty()
		set_physics_process(false)
		return

	start_y = moving_spike.position.y

	trigger.body_entered.connect(_on_trigger_entered)


# Fall when player enters trigger area

func _on_trigger_entered(body: Node2D) -> void:
	print("Trigger detected: ", body.name)
	print("Is player: ", body.is_in_group("player"))

	if activated or not body.is_in_group("player"):
		return

	activated = true

	await get_tree().create_timer(warning_delay).timeout

	if not is_inside_tree():
		return

	falling = true



func _physics_process(delta: float) -> void:
	if not falling:
		return

	var traveled := moving_spike.position.y - start_y
	var remaining := max_fall_distance - traveled

	if remaining <= 0.0:
		falling = false
		return

	var step: float = minf(fall_speed * delta, remaining)

	# Stops when hitting ground
	# ground_ray.target_position = Vector2(0, step + 2.0)
	# ground_ray.force_raycast_update()

	#if ground_ray.is_colliding():
	#	var ground_y := ground_ray.get_collision_point().y
	#	var gap: float = maxf(0.0, ground_y - ground_ray.global_position.y - 1.0)

	#	moving_spike.position.y += min(step, gap)
	#	falling = false
	#	return

	moving_spike.position.y += step

# Needs to be linked to damage script
#func _on_hitbox_entered(body: Node2D) -> void:
#	if body.is_in_group("player"):
