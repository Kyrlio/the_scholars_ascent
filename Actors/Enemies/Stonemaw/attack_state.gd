extends EnemyState

func enter() -> void:
	context.velocity.x = 0.0
	context.animation_player.play("attack")
	
	context.hurtbox_component.is_invincible = false
	
	await context.animation_player.animation_finished
	if context.state != self: return
	
	context.animation_player.play("idle_outside")
	await context.get_tree().create_timer(randf_range(3.0, 4.0)).timeout
	if context.state != self: return
	
	context.set_state($"../ChaseState")

func exit() -> void:
	context.hurtbox_component.is_invincible = true
