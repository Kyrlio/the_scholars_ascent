extends EnemyState


func enter() -> void:
	context.animation_player.play("run")
	context.hurtbox_component.is_invincible = true

func physics_update(_delta: float) -> void:
	var player = _get_player_in_vision()
	
	if player:
		context.direction = sign(player.global_position.x - context.global_position.x)
		
		if _is_player_in_attack_range():
			context.set_state($"../AttackState")
			return
		
		if context.wall_detection_ray.is_colliding() or not context.ledge_detection_ray.is_colliding():
			context.velocity.x = 0.0
			context.set_state($"../IdleState")
		else:
			context.velocity.x = context.chase_speed * context.direction
	else:
		context.set_state($"../IdleState")


func _get_player_in_vision() -> Player:
	for body in context.vision_area.get_overlapping_bodies():
		if body is Player:
			return body
	return null

func _is_player_in_attack_range() -> bool:
	for body in context.melee_area.get_overlapping_bodies():
		if body is Player:
			return true
	return false
