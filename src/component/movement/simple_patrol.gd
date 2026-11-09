class_name SimplePatrol
extends Component

signal edge_reached()

## How far ahead, in pixels, an edge is looked for
@export var edge_lookahead: float = 16

## How long before the actor waits to turn around after reaching the edge of 
## a platform
@export var edge_pause_time: float = 1

## Initial movement direction, -1 for left, 1 for right
@export var move_dir: float = 1

var movement: Movement = null
var _edge_detector: Area2D = null
var _wall_detector: Area2D = null
var _movement_wait: float = 0
var _do_edge_overlap_check: bool = true

var actor: CollisionObject2D:
	get: return entity as CollisionObject2D

func _create_detectors() -> void:
	if _wall_detector:
		_wall_detector.queue_free()
	if _edge_detector:
		_edge_detector.queue_free()
	
	var actor_collider_minmax := Ladder.calc_minmax(actor)
	var actor_height := actor_collider_minmax[1].y - actor_collider_minmax[0].y
	
	var wall_detector_shape := RectangleShape2D.new()
	wall_detector_shape.size = Vector2(1, actor_height - 2)
	
	var _wall_detector_collision := CollisionShape2D.new()
	_wall_detector_collision.shape = wall_detector_shape
	_wall_detector = Area2D.new()
	_wall_detector.monitoring = true
	_wall_detector.collision_layer = 0
	_wall_detector.collision_mask = actor.collision_mask
	_wall_detector.add_child(_wall_detector_collision)
	_wall_detector.body_entered.connect(_on_wall_detector_overlap)
	
	var edge_detector_shape := CircleShape2D.new()
	edge_detector_shape.radius = 1
	
	var _edge_detector_collision := CollisionShape2D.new()
	_edge_detector_collision.shape = edge_detector_shape
	_edge_detector = Area2D.new()
	_edge_detector.monitoring = true
	_edge_detector.collision_layer = 0
	_edge_detector.collision_mask = actor.collision_mask
	_edge_detector.add_child(_edge_detector_collision)
	_edge_detector.body_exited.connect(_on_edge_detector_exit)
	
	# add the detectors to the actor
	actor.add_child.call_deferred(_wall_detector)
	actor.add_child.call_deferred(_edge_detector)
	
	# position the detectors at the bottom and to the right of the detector
	var actor_bottom_y := actor_collider_minmax[1].y
	var actor_midsection_y := (
		actor_collider_minmax[0].y + actor_collider_minmax[1].y
	) * 0.5
	_wall_detector.position.y = actor_midsection_y
	_edge_detector.position.y = actor_bottom_y + 2
	_wall_detector.position.x = edge_lookahead * signf(move_dir)
	_edge_detector.position.x = edge_lookahead * signf(move_dir)

func _on_wall_detector_overlap(_other: Node2D) -> void:
	edge_reached.emit()
	stop_at_edge()

func _on_edge_detector_exit(_other: Node2D) -> void:
	_do_edge_overlap_check = true

func _edge_overlap_check() -> void:
	var overlapped := false
	var bodies := _edge_detector.get_overlapping_bodies()
	for body in bodies:
		if body != actor:
			overlapped = true
	if not overlapped:
		edge_reached.emit()
		stop_at_edge()

func _position_detectors() -> void:
	_edge_detector.position.x = edge_lookahead * signf(move_dir)
	_wall_detector.position.x = edge_lookahead * signf(move_dir)

func _ready() -> void:
	assert(entity is CollisionObject2D)
	movement = Component.get_component(entity, GroundMovement)
	assert(movement != null)
	
	_create_detectors()
	
func _physics_process(delta: float) -> void:
	if _do_edge_overlap_check:
		_do_edge_overlap_check = false
		_edge_overlap_check()
	
	if _movement_wait > 0:
		_movement_wait -= delta
		if _movement_wait <= 0:
			_movement_wait = 0
			move_dir = -signf(move_dir)
			_position_detectors()
			_do_edge_overlap_check = true
		else:
			movement.move_vector = Vector2(0, 0)
			return
	
	movement.move_vector = Vector2(move_dir, 0)

func stop_at_edge(flip: bool = true) -> void:
	if not flip: move_dir *= -1
	_movement_wait = edge_pause_time
