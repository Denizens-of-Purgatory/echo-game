class_name RigidbodyForceIntegrator
extends RigidBody2D

## signal is emitted when _integrate_forces is called on this body
signal on_integrate_forces(state: PhysicsDirectBodyState2D)

func _ready() -> void:
	custom_integrator = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.integrate_forces()
	on_integrate_forces.emit(state)
