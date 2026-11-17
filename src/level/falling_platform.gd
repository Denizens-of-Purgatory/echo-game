extends StaticBody2D

# Disappear Timer
@export var disappear_delay: float = 2.0

# Respawn Timer
@export var respawn_delay: float = 5.0

@onready var tiles: TileMapLayer = $TileMapLayer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var trigger: Area2D = $TopTrigger

var activated: bool = false


func _ready() -> void:
	trigger.body_entered.connect(_on_trigger_entered)



func _on_trigger_entered(body: Node2D) -> void:

	if activated or not body.is_in_group("player"):
		return

	activated = true

	# Wait before disappearing
	await get_tree().create_timer(disappear_delay).timeout

	if not is_inside_tree():
		return

	# Hide platform and disable collision
	tiles.hide()
	collision.set_deferred("disabled", true)


	# Respawn platform
	if respawn_delay > 0:
		await get_tree().create_timer(respawn_delay).timeout

		if not is_inside_tree():
			return

		collision.set_deferred("disabled", false)
		tiles.show()
		activated = false
