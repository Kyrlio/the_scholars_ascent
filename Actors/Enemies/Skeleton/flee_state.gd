extends EnemyState


func enter() -> void:
	context.animation_player.play("walk")


func physics_update(_delta: float) -> void:
	if not context.player:
		print("Skeleton Flee State : no player")
		context.set_state($"../PatrolState")
	
	var is_player_in_flee_area: bool = context.flee_area.overlaps_body(context.player)
	if is_player_in_flee_area:
		var flee_dir = -sign(context.player.global_position.x - context.global_position.x)
		if flee_dir == 0: flee_dir = 1.0
		
		if context.attack_timer.is_stopped():
			context.velocity.x = 0.0
			context.direction = -flee_dir
			context.update_facing()
			context.set_state($"../AttackState")
			return
		
		context.direction = flee_dir
		context.update_facing()
		context.wall_detection_ray.force_raycast_update()
		context.ledge_detection_ray.force_raycast_update()
		
		if context.wall_detection_ray.is_colliding() or not context.ledge_detection_ray.is_colliding():
			context.velocity.x = 0.0
			
			context.direction = -flee_dir
			context.update_facing()
			context.animation_player.play("idle")
		else:
			context.velocity.x = context.flee_speed * context.direction
			context.animation_player.play("walk")
	else:
		if is_instance_valid(context.player):
			context.direction = sign(context.player.global_position.x - context.global_position.x)
			context.update_facing()
		context.set_state($"../PatrolState")
