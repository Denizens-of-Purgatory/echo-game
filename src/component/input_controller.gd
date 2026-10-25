class_name InputController
extends Node

@export var movement: Movement = null

@export var control_moveRight: StringName = &"move_right"
@export var control_moveLeft: StringName = &"move_left"
@export var control_moveDown: StringName = &"move_down"
@export var control_moveUp: StringName = &"move_up"
@export var control_jump: StringName = &"jump"
@export var control_melee: StringName = &"melee"

var action_ids: Array[StringName] = []
var action_pressed_map: Dictionary[StringName, bool] = {}

func _ready() -> void:
	action_ids = [
		control_moveLeft, 
		control_moveRight,
		control_moveDown,
		control_moveUp,
		control_jump,
		control_melee,
	]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_type():
		for id in action_ids:
			if event.is_action(id):
				action_pressed_map.set(id, event.is_pressed())

func _process(_delta: float) -> void:
	
	if(movement == null): _find_movement()
	
	var move_input: Vector2 = Vector2.ZERO
	if is_action_pressed(control_moveLeft):
		move_input.x -= 1
	if is_action_pressed(control_moveRight):
		move_input.x += 1
	if is_action_pressed(control_moveDown):
		move_input.y += 1
	if is_action_pressed(control_moveUp):
		move_input.y -= 1
	movement.move(move_input)
	
	if is_action_pressed(control_jump):
		movement.jump()

func _find_movement() -> void:
	print("getting ground movement for controller..")
	var parent := get_parent()
	if parent is CharacterRigidbody2D and parent.ground_movement != null:
		movement = parent.ground_movement
		print("found ground movement for controller!")

func is_action_pressed(action_id: StringName) -> bool:
	return action_pressed_map.get(action_id, false)
