class_name GameManager
extends Node

signal on_paused()
signal on_resumed()

@export var music_player: MusicPlayer = null
@export var camera: Camera2D = null
@export var hero: Hero = null

var currentLevel: Level = null
var elapsed_time: float = 0

var _is_paused: bool = false

var is_paused: bool:
	get: return _is_paused

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event.is_action("pause_game"):
		if is_paused: resume()
		else: pause()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not _is_paused:
		elapsed_time += delta

func pause() -> void:
	if _is_paused: return
	
	get_tree().paused = true
	
	_is_paused = true
	on_paused.emit()

func resume() -> void:
	if not _is_paused: return
	
	get_tree().paused = false
	
	_is_paused = false
	on_resumed.emit()
