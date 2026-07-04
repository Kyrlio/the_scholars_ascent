extends EnemyState

func enter() -> void:
	context.hitbox_component.set_deferred("monitoring", true)
	context.hitbox_component.set_deferred("monitorable", true)
	context.hurtbox_component.set_deferred("monitoring", true)

func physics_update(_delta: float) -> void:
	var player: Player = _get_player_in_vision()
	
	if player:
		context.update_facing(player.global_position)
		
		var target_pos = player.global_position + Vector2(0, -context.hover_altitude)
		
		var dir := context.global_position.direction_to(target_pos)
		context.velocity = dir * context.chase_speed
		
		if _is_player_in_attack_range() and context.attack_timer.is_stopped():
			context.set_state($"../AttackState")
	else:
		context.set_state($"../IdleState")

func exit() -> void:
	pass


func _get_player_in_vision() -> Player:
	for body in context.vision_area.get_overlapping_bodies():
		if body is Player:
			return body
	return null


func _is_player_in_attack_range() -> bool:
	for body in context.attack_area.get_overlapping_bodies():
		if body is Player:
			return true
	return false


func _on_attack_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		context.last_player_position = body.global_position
