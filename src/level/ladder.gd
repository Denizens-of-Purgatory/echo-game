class_name Ladder
extends Node

static func find(root: Node) -> Ladder:
	for child in root.get_children(true):
		if child is Ladder:
			return child
	return null

static func calc_minmax(collision_obj: CollisionObject2D) -> Array[Vector2]:
	var minp: Vector2 = Vector2(INF, INF)
	var maxp: Vector2 = Vector2(-INF, -INF)
	for child in collision_obj.get_children():
		if child is CollisionShape2D and child.shape:
			var col := child as CollisionShape2D
			var rect: Rect2 = col.transform * col.shape.get_rect()
			minp = minp.min(rect.position)
			maxp = maxp.max(rect.end)
	return [minp, maxp]

@export var parent: Area2D = null

## reference all the colliders here that should be ignored while the ladder is 
## being climbed
@export var ignore_colliders: Array[PhysicsBody2D] = []

var _min_pos: Vector2 = Vector2(INF, INF)
var _max_pos: Vector2 = Vector2(-INF, -INF)

func _ready() -> void:
	var minmax := calc_minmax(parent)
	_min_pos = minmax[0]
	_max_pos = minmax[1]

## The y value of the top of the ladder
func top_y() -> float:
	return (parent.global_transform * _min_pos).y

## The y value of the bottom of the ladder
func bottom_y() -> float:
	return (parent.global_transform * _max_pos).y
