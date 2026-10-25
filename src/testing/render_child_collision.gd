## Render all CollisionCobjects that are children of the parent
class_name RenderChildCollision
extends Node

@export var fill_color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK
@export var outline_thickness: float = 1.0

func _ready() -> void:
	for collision in get_children():
		if collision is CollisionObject2D:
			var render := RenderCollision.new()
			render.fill_color = fill_color
			render.outline_color = outline_color
			render.outline_thickness = outline_thickness
			collision.add_child(render)
	
