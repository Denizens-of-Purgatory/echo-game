class_name Hero
extends Actor

@export var input_controller: InputController = null
@export var ladder_user: LadderUser = null

func _ready() -> void:
	if is_instance_valid(Game.hero):
		push_warning("Multiple hero nodes cannot exist in the game at once")
		queue_free()
	else:
		Game.hero = self

func _on_die() -> void:
	ladder_user.stop_climbing()
	input_controller.queue_free()
	movement[0].move_vector = Vector2.ZERO

func _on_revive() -> void:
	pass
