extends EnemyState


func enter() -> void:
	context.velocity.x = 0.0
	context.animation_player.play("hit")
	GameEvents.emit_camera_shake(0.2)
	
	await context.animation_player.animation_finished
	
	if context.health_component.current_health > 0:
		context.set_state($"../DefenseState")


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass
