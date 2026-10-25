class_name Movement
extends Node

## Returns the first Movement child of the specified parent, or null if none 
## found. Does not search nested children
static func get_from(parent: Node) -> Movement:
	if parent is Actor: return parent.movement
	for child in parent.get_children():
		if child is Movement:
			return child as Movement
	return null

## Returns all Movement children of the specified parent, or null if none 
## found. Does not search nested children
static func get_all_from(parent: Node) -> Array[Movement]:
	if parent is Actor: return parent.movement
	var arr: Array[Movement] = []
	for child in parent.get_children():
		if child is Movement:
			arr.push_back(child as Movement)
	return arr

## Whether the movement script does anything. NOTE this must be implemented 
## manually for each movement capability if the base Movement class is 
## inherited from
@export var _active: bool = true

## the max speed that the actor can accelerate to
@export var max_speed: float = 300

## how quickly the actor reaches their max speed, with a factor of 1, it takes
## one second, with a factor of 2 it takes 1/2 second, etc
@export var acceleration_factor: float = 5

var move_vector: Vector2 = Vector2.ZERO

func set_active(is_active: bool):
	_active = is_active

## Instructs the movement component to move in the specified direction
func move(_move_dir: Vector2, _clamp_to_one: bool = true) -> void:
	push_error("Not implemented")
