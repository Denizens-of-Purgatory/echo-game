class_name Targeting
extends Component

@export var target: Node2D = null
@export var raycast: RayCast2D = null
@export var target_hero: bool = false

func _ready() -> void:
	if target_hero:
		target = Game.hero
