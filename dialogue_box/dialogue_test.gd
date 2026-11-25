extends Node

func _ready() -> void:
	$DialogueBox.start([
		{"name": "Bob The Builder", "portrait": preload("res://dialogue_box/icon.svg"), "text": "Gasp!"},
		{"name": "Bob The Builder", "portrait": preload("res://dialogue_box/icon.svg"), "text": "My eye!"},
	])
	$DialogueBox.dialogue_finished.connect(get_tree().quit)
