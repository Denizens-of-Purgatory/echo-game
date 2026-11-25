class_name DialogueBox
extends Control

signal line_finished      # a line finished typing
signal dialogue_finished  # all lines done, box closed

@export var chars_per_second: float = 40.0
@export var advance_action: StringName = &"ui_accept"

@onready var portrait: TextureRect = %Picture
@onready var name_label: Label = %SpeakerLabel
@onready var text_label: RichTextLabel = %Dialogue

var _lines: Array = []
var _index := -1
var _tween: Tween
var _typing := false


func _ready() -> void:
	text_label.bbcode_enabled = true
	visible = false


# lines = [{ "name": "Bob", "portrait": preload("res://icon.svg"), "text": "Hello!" }, ...]
func start(lines: Array) -> void:
	_lines = lines
	_index = -1
	_open()
	_next()


func _next() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
		return

	var line: Dictionary = _lines[_index]
	name_label.text = line.get("name", "")
	portrait.texture = line.get("portrait", null)
	text_label.text = line.get("text", "")
	text_label.visible_characters = 0

	var total := text_label.get_total_character_count()
	_typing = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(text_label, "visible_characters", total, total / chars_per_second)
	_tween.finished.connect(_on_typing_done)


func _on_typing_done() -> void:
	_typing = false
	line_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed(advance_action):
		return
	get_viewport().set_input_as_handled()
	if _typing:
		# skip to the end of the current line
		_tween.kill()
		text_label.visible_characters = -1
		_on_typing_done()
	else:
		_next()


# --- Open / close: swap these bodies out for animations later ---
func _open() -> void:
	visible = true


func _close() -> void:
	visible = false
	dialogue_finished.emit()
