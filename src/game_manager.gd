class_name GameManager
extends Node

@export var camera: Camera2D = null
@export var hero: Hero = null
var currentLevel: Level = null
var elapsed_time: float = 0

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
			
		for child2 in child.get_children():
			if child2 is Hero:
				hero = child2
			if hero: break
			
		if hero: break
		
	if hero:
		print("Found hero '%s'" % [hero.name])

func _search_for_camera() -> void:
	for child in get_tree().root.get_children():
		if child is Camera2D:
			camera = child
			
		for child2 in child.get_children():
			if camera and child2 is Camera2D:
				camera = child2
			if camera: break
			
		if camera: break

	if camera:
		camera.reparent.call_deferred(get_tree().root)
		print("Found camera")

func _ready() -> void:
	if not hero: _search_for_hero()
	if not camera: _search_for_camera()
	if not currentLevel: _search_for_level()
	
	if hero:
		hero.reparent.call_deferred(get_tree().root)
		if camera:
			var cam_follow := Component.get_component(camera, CameraFollow) as CameraFollow
			if cam_follow:
				cam_follow.target = hero
	
	print("Game manager ready")

func _process(delta: float) -> void:
	elapsed_time += delta
