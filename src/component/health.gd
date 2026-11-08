class_name Health
extends Node

signal on_health_depleted()

@export var actor: Node = null
@export var death: Death = null
@export var max_health: float = 10
@export var _health: float = 0

## Refill health when the actor is added to the scene
@export var fill_health: bool = true

var _health_depleted: bool = false

var health: float:
	get: return _health
	set(value):
		if _health_depleted and value > 0:
			_health_depleted = false
			if death: death.revive()
		elif not _health_depleted and value <= 0:
			_health_depleted = true
			on_health_depleted.emit()
			if death: death.die()
		_health = clampf(value, 0, max_health)

func _ready() -> void:
	if fill_health:
		fill_health = false
		health = max_health

func _on_damage_recieved(damage: float) -> void:
	health -= damage
