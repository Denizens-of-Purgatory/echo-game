class_name GameManager
extends Node

var hero: Hero = null
var currentLevel: Level = null
var camera: Camera2D = null
var elapsed_time: float = 0

func _search_for_level() -> void:
	for child in get_tree().root.get_children():
		var level := Component.find_uninitialized_component(child, Level) as Level
		if level:
			print("Found level '%s'" % [level.level_title])
			Level.start_level(level)
			break

func _search_for_hero_and_camera() -> void:
	for child in get_tree().root.get_children():
		if child is Hero:
			hero = child
		elif child is Camera2D:
			camera = child
			
		for child2 in child.get_children():
			if child2 is Hero:
				hero = child2
			elif child2 is Camera2D:
				camera = child2
			if hero and camera: break
			
		if hero and camera: break
		
	if hero:
		hero._skip_singleton_check = true
		hero.reparent.call_deferred(get_tree().root)
		print("Found hero '%s'" % [hero.name])
	if camera:
		camera.reparent.call_deferred(get_tree().root)
		print("Found camera")

func _ready() -> void:
	if (not hero) or (not camera): _search_for_hero_and_camera()
	if not currentLevel: _search_for_level()
	print("Game manager ready")

func _process(delta: float) -> void:
	elapsed_time += delta
