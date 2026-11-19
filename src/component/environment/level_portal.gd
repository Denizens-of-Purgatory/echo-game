class_name  LevelPortal
extends Component

@export var next_level_scene: PackedScene = null
@export var cutscene: PackedScene = null

func _ready() -> void:
	assert(entity is Area2D)
	var area := entity as Area2D
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is Hero: return
	var level := Level.load_level(next_level_scene)
	Level.start_level(level)
