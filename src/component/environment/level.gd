class_name Level
extends Component

static func convert_to_level(node: Node) -> Level:
	var level := Component.find_uninitialized_component(node, Level) as Level
	if not level:
		level = Level.new()
		node.add_child(level)
	
	# search for player to use as spawn point
	if not level.spawn_point:
		for child in node.get_children():
			if child is Hero:
				level.spawn_point = child
				break
	
	# convert spawn point to to plain 2D Node
	if level.spawn_point is Hero:
		var new_spawn_point := Node2D.new()
		level.add_child(new_spawn_point)
		new_spawn_point.global_position = level.spawn_point.global_position
		level.spawn_point = new_spawn_point
	
	return level

static func load_level(scene: PackedScene) -> Level:
	var level_node: Node = scene.instantiate()
	var level := Component.find_uninitialized_component(level_node, Level)
	if level == null:
		level = convert_to_level(level_node)
	return level

static func start_level(level: Level) -> void:
	# unload the previous level
	if is_instance_valid(Game.currentLevel):
		Game.currentLevel.on_end.emit()
		Game.currentLevel.queue_free()
	
	# add the level to the scene
	if not level.entity.get_parent():
		Game.get_tree().root.add_child(level.entity)
	
	# start the next level
	Game.hero.global_position = level.spawn_point.global_position
	Game.currentLevel = level
	level.on_start.emit()
	
	print("Starting level: %s" % [level.level_title])

signal on_start()
signal on_end()

@export var level_title: String = "Default Level Name"
@export var spawn_point: Node2D = null

var elapsed_time: float = 0

func _ready() -> void:
	if false: on_end.emit() # just to silence the false compiler warning
	
	# assert only properly loaded levels are added to the scene
	assert(Game.currentLevel == self)

func _process(delta: float) -> void:
	elapsed_time += delta
