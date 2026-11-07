class_name Hero
extends CharacterRigidbody2D

func _on_die() -> void:
	var parent := get_parent()
	parent.remove_child(self)

func _on_revive() -> void:
	pass
