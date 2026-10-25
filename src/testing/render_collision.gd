## Render CollisionShapes that belong to the parent as simple shapes
class_name RenderCollision
extends Node

@export var fill_color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK
@export var outline_thickness: float = 2

var collision_shapes: Array[CollisionShape2D] = []
var _collision_shapes_dirty: bool = true

var _polygons: Array[Polygon2D] = []
var _outlines: Array[Line2D] = []

var _parent: Node = null

func _enter_tree() -> void:
	if _parent != null:
		_parent.child_entered_tree.disconnect(_on_siblings_changed)
		_parent.child_exiting_tree.disconnect(_on_siblings_changed)
	_parent = get_parent()
	_parent.child_entered_tree.connect(_on_siblings_changed)
	_parent.child_exiting_tree.connect(_on_siblings_changed)

func _process(_delta: float) -> void:
	# refresh collision shape list and polygons if dirty
	if _collision_shapes_dirty:
		collision_shapes = find_collision_shapes()
		_collision_shapes_dirty = false
		refresh_render_shapes()

func _on_siblings_changed(sibling: Node):
	if sibling is CollisionShape2D:
		_collision_shapes_dirty = true

## iterate through each sibling and add them to a list if they are a collision shape
func find_collision_shapes() -> Array[CollisionShape2D]:
	var shapes: Array[CollisionShape2D] = []
	var parent := get_parent()
	for child in parent.get_children():
		if child is CollisionShape2D:
			shapes.push_back(child)
	return shapes

func refresh_render_shapes() -> void:
	# remove old shapes
	for poly in _polygons:
		poly.queue_free()
	_polygons.clear()
	for line in _outlines:
		line.queue_free()
	_outlines.clear()
	
	# create new polygons
	_polygons.append_array(create_fill_polygons())
	if outline_thickness > 0:
		_outlines.append_array(create_outline_polygons())

## get the approximate vertices of a Shape2D
func shape_to_verts(shape: Shape2D, transform: Transform2D) -> PackedVector2Array:
	var verts: PackedVector2Array = []
	
	if shape is RectangleShape2D:
		var size: Vector2 = shape.size
		verts.push_back(transform * Vector2(size.x * 0.5, size.y * 0.5))
		verts.push_back(transform * Vector2(size.x * 0.5, size.y * -0.5))
		verts.push_back(transform * Vector2(size.x * -0.5, size.y * -0.5))
		verts.push_back(transform * Vector2(size.x * -0.5, size.y * 0.5))
	
	elif shape is CapsuleShape2D:
		var radius: float = shape.radius
		var height: float = shape.height
		var radial_points := 12
		var radial_points_half := radial_points / 2.0
		var height_off := height * 0.5 - radius
		for i in radial_points + 1:
			var theta: float = (i / float(radial_points)) * PI * 2
			var y_off := height_off if i <= radial_points_half else -height_off
			var off := Vector2(cos(theta) * radius, sin(theta) * radius + y_off)
			verts.push_back(transform * off)
			if i == radial_points_half:
				var off2 := Vector2(cos(theta) * radius, sin(theta) * radius - y_off)
				verts.push_back(transform * off2)
	
	elif shape is CircleShape2D:
		var radius: float = shape.radius
		var points := 12
		for i in points:
			var theta: float = (i / float(points)) * PI * 2
			var off := Vector2(cos(theta) * radius, sin(theta) * radius)
			verts.push_back(transform * off)
	
	else: push_error("invalid shape: ", shape)
	
	return verts

func create_fill_polygons() -> Array[Polygon2D]:
	var polys: Array[Polygon2D] = []
	for shape_node in collision_shapes:
		var verts := shape_to_verts(shape_node.shape, Transform2D.IDENTITY)
		if len(verts) <= 0: continue
		
		var poly := Polygon2D.new()
		poly.polygon = verts
		poly.color = fill_color
		shape_node.add_child(poly)
		polys.push_back(poly)
	
	return polys

func create_outline_polygons() -> Array[Line2D]:
	var lines: Array[Line2D] = []
	for shape_node in collision_shapes:
		var verts := shape_to_verts(shape_node.shape, Transform2D.IDENTITY)
		if len(verts) <= 0: continue
		
		var line := Line2D.new()
		line.points = verts
		line.closed = true
		line.default_color = outline_color
		line.width = outline_thickness
		shape_node.add_child(line)
		lines.push_back(line)
	
	return lines
