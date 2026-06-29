extends EnemyState


func enter() -> void:
	context.velocity.x = 0.0
	
	if context.player:
		context.direction = sign(context.player.global_position.x - context.global_position.x)
		context.update_facing()
	
	context.animation_player.play("attack")
	context.attack_timer.start()
	
	await context.animation_player.animation_finished
	if context.state != self: return
	
	var is_player_in_flee_area: bool = context.flee_area.overlaps_body(context.player)
	if is_player_in_flee_area:
		context.set_state($"../FleeState")
	else:
		context.set_state($"../PatrolState")
