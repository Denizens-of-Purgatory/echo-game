class_name Component
extends Node

const META_KEY: StringName = &"_components"

## Get the component of the specified script type attached to the specified 
## node. If `include_disabled` is false, the component will not be returned if
## it's `enabled` field is set to false.
static func get_component(node: Node, script: Script, include_disabled: bool = false) -> Component:
	if not node.has_meta(META_KEY): return null
	var components: Dictionary[Script, Component] = node.get_meta(META_KEY, {})
	var comp: Component = components.get(script, null)
	if include_disabled or (comp and comp.enabled): 
		return comp
	return null

signal on_enabled()
signal on_disabled()

## Emitted when the component is first attached to it's parent entity
signal on_attached(entity: Node)

## Emitted when the component is detached from it's parent entity
signal on_detached(entity: Node)

## The node entity that the component is attached to and acts upon
@export var _entity: Node = null

## If not enabled, the component shouldn't affect the behavior of it's entity
@export var _enabled: bool = true



## The node entity that the component is attached to and acts upon
var entity: Node:
	get: return _entity

## If not enabled, the component shouldn't affect the behavior of it's entity
var enabled: bool:
	get: return _enabled
	set(value):
		if value != _enabled:
			_enabled = value
			if _enabled: on_enabled.emit()
			else: on_disabled.emit()



## Be sure to call `super._enter_tree()` for the component if this method 
## is overriden, otherwise component behavior will not work
func _enter_tree() -> void:
	attach(entity)

## Be sure to call `super._exit_tree()` for the component if this method 
## is overriden, otherwise component behavior will not work
func _exit_tree() -> void:
	detach()

## Detach a component from it's parent entity if it has one
func detach() -> void:
	if not entity: return
	var components := entity.get_meta(META_KEY) as Dictionary[Script, Component] 
	components.erase(get_script())
	_entity = null
	on_detached.emit()

## Attach a component to the specified node entity
func attach(node_entity: Node):
	if entity == node_entity: return
	if entity: detach()
	
	var components: Dictionary[Script, Component]
	var script: Script = get_script()
	
	if not node_entity.has_meta(META_KEY):
		components = {}
		node_entity.set_meta(META_KEY, components)
	else: 
		components = node_entity.get_meta(META_KEY)
		var comp: Component = components.get(script)
		if comp != self:
			push_error(
				"entity '%s' already has component of type '%s'" % 
				[node_entity, script.get_global_name()]
			)
			return
	
	components.set(script, self)
	_entity = node_entity
	on_attached.emit(_entity)
