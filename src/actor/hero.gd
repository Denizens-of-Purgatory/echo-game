class_name Hero
extends CharacterRigidbody2D

@export var input_controller: InputController = null
@export var ladder_user: LadderUser = null

func _on_die() -> void:
	ladder_user.stop_climbing()
	input_controller.queue_free()
	movement[0].move_vector = Vector2.ZERO

func _on_revive() -> void:
	pass
