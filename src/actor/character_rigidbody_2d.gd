class_name CharacterRigidbody2D
extends Actor

var ground_detection: GroundDetection = null
var ground_movement: GroundMovement = null

var _readied: bool = false

func get_component_owner() -> Node:
	if self.owner == null or (not scene_file_path.is_empty()): return self
	return self.owner

## force get the ground detection, by creating or finding it if null
func get_ground_detection() -> GroundDetection:
	if ground_detection == null: 
		attach_ground_detection()
	return ground_detection

## force get the ground movement, by creating or finding it if null
func get_ground_movement() -> GroundMovement:
	if ground_movement == null:
		attach_ground_movement()
	return ground_movement

## prepare components when character body is created
func _ready() -> void:
	super._ready()
	if ground_detection == null: attach_ground_detection()
	if ground_movement == null: attach_ground_movement()
	enforce_component_requirements()
	_readied = true

## attach ground detecion component (or search for it if in editor)
func attach_ground_detection() -> void:
	if Engine.is_editor_hint():
		for child in get_children(true):
			if child is GroundDetection:
				ground_detection = child
				ground_detection.actor = self
				return
	
	print("attaching new ground detection component..")
	ground_detection = GroundDetection.new()
	ground_detection.actor = self
	add_child(ground_detection, false, Node.INTERNAL_MODE_FRONT)
	ground_detection.owner = get_component_owner()

# attach ground movement component (or search for it if in editor)
func attach_ground_movement() -> void:
	if Engine.is_editor_hint():
		for child in get_children(true):
			if child is GroundMovement:
				ground_movement = child
				ground_movement.actor = self
				if ground_detection != null: ground_movement.ground_detection = ground_detection
				return
	
	print("attaching new ground movement component..")
	ground_movement = GroundMovement.new()
	ground_movement.actor = self
	if ground_detection != null: ground_movement.ground_detection = ground_detection
	add_child(ground_movement, false, Node.INTERNAL_MODE_FRONT)
	ground_movement.owner = get_component_owner()

## re-order physics integration so that ground detection is always run first
func reorder_physics_integration() -> void:
	if Engine.is_editor_hint(): return
	
	if ground_movement != null:
		if on_integrate_forces.is_connected(ground_movement._actor_integrate_forces):
			on_integrate_forces.disconnect(ground_movement._actor_integrate_forces)
	
	if ground_detection != null:
		if not on_integrate_forces.is_connected(ground_detection._actor_integrate_forces):
			on_integrate_forces.connect(ground_movement._actor_integrate_forces)
	
	if ground_movement != null:
		on_integrate_forces.connect(ground_movement._actor_integrate_forces)

## checks that the required references for the ground detection and ground 
## movement in the child components are met
func enforce_component_requirements() -> void:
	ground_movement.ground_detection = ground_detection
	reorder_physics_integration()
