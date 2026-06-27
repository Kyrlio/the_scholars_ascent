extends EnemyState

func enter() -> void:
	print("attacking")
	context.hurtbox_component.toggle_invincibility(false)
	context.velocity.x = 0.0
	context.attack_timer.start()
	context.animation_player.play("attack")
	
	await context.animation_player.animation_finished
	
	context.state = previous_state

func physics_update(_delta: float) -> void:
	pass

func exit() -> void:
	pass
