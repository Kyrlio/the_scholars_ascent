extends EnemyState


var is_active: bool = false

func enter() -> void:
	is_active = true
	context.velocity.x = 0.0
	context.animation_player.play("hit")
	GameEvents.emit_camera_shake(0.2)
	
	await context.animation_player.animation_finished
	if not is_active or context.state != self: return
	
	if context.health_component.current_health > 0:
		context.set_state($"../ChaseState")

func exit() -> void:
	is_active = false
