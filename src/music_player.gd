class_name MusicPlayer
extends Node

@export var gameplay_loop: AudioStream = null
@export var audio_player: AudioStreamPlayer = null

func _ready() -> void:
	audio_player.stream = gameplay_loop

func _process(_delta: float) -> void:
	if not Game.is_paused:
		if not audio_player.playing:
			audio_player.play()
	elif audio_player.playing:
		audio_player.stop()
