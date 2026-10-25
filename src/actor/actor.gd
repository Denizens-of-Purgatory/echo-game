class_name Actor
extends RigidbodyForceIntegrator

@export var title: String = "Actor"
@export var movement: Array[Movement] = []

var is_alive: 
	get: return true

func _to_string() -> String:
	return title
