class_name Hero
extends Actor

@export var input_controller: InputController = null
@export var ladder_user: LadderUser = null

func _ready() -> void:
	super._ready()
	if is_instance_valid(Game.hero) and not Game.hero == self:
		push_warning("Multiple hero nodes cannot exist in the game at once")
		queue_free()
	else:
		Game.hero = self

func _on_die() -> void:
	ladder_user.stop_climbing()
	input_controller.queue_free()
	
	var movement_vec: MovementVector = Component.get_component(self, MovementVector)
	if movement_vec: movement_vec.movement_vector = Vector2.ZERO

func _on_revive() -> void:
	pass
