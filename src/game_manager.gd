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

func _search_for_hero() -> void:
	for child in get_tree().root.get_children():
		if child is Hero:
			hero = child
			break
		var hero_found := false
		for child2 in child.get_children():
			if child2 is Hero:
				hero = child2
				hero_found = true
				break
		if hero_found:
			break
	if hero:
		hero._skip_singleton_check = true
		print("Found hero '%s'" % [hero.name])

func _ready() -> void:
	if not hero: _search_for_hero()
	if not currentLevel: _search_for_level()
	print("Game manager ready")

func _process(delta: float) -> void:
	elapsed_time += delta
