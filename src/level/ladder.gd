class_name Ladder
extends Node

static func find(root: Node) -> Ladder:
	for child in root.get_children(true):
		if child is Ladder:
			return child
	return null

@export var parent: Area2D = null

## reference all the colliders here that should be ignored while the ladder is 
## being climbed
@export var ignore_colliders: Array[PhysicsBody2D] = []

var _min_pos: Vector2 = Vector2(INF, INF)
var _max_pos: Vector2 = Vector2(-INF, -INF)

func _ready() -> void:
	for child in parent.get_children():
		if child is CollisionShape2D and child.shape:
			var col := child as CollisionShape2D
			var rect: Rect2 = col.transform * col.shape.get_rect()
			_min_pos = _min_pos.min(rect.position)
			_max_pos = _max_pos.max(rect.end)

## The y value of the top of the ladder
func top_y() -> float:
	return (parent.global_transform * _min_pos).y

## The y value of the bottom of the ladder
func bottom_y() -> float:
	return (parent.global_transform * _max_pos).y
