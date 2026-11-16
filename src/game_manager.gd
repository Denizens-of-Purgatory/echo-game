class_name GameManager
extends Node

@export var hero: Hero = null
@export var currentLevel: Level = null
@export var elapsed_time: float = 0

func _search_for_level() -> void:
	for child in get_tree().root.get_children():
		var level := Component.find_uninitialized_component(child, Level) as Level
		if level:
			print("Found level '%s'" % [level.level_title])
			Level.start_level(level)
			break

func _ready() -> void:
	_search_for_level()
	print("Game manager ready")

func _process(delta: float) -> void:
	elapsed_time += delta
