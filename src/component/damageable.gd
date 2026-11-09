class_name Damageable
extends Component

static func get_component(
	node: Node, script: Script = Damageable, include_disabled: bool = false
) -> Damageable:
	assert(script == Damageable)
	return Component.get_component(node, script, include_disabled) as Damageable

signal on_damaged(damage: float)

## Just an overload for on_damaged but it emits no arguments
signal on_damaged_noarg()

## If true, can still recieve damage when the death component reports dead
@export var enabled_while_dead: bool = false

func damage(dmg: float):
	if not enabled: return
	if not enabled_while_dead:
		var death := Component.get_component(entity, Death) as Death
		if death and death.is_dead: return
	on_damaged.emit(dmg)
	on_damaged_noarg.emit()
