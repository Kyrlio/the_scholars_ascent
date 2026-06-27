extends EnemyState

func enter() -> void:
	context.velocity = Vector2.ZERO
	context.animation_player.play("charge")
	
	context.attack_timer.start()
	
	await context.animation_player.animation_finished
	if context.state != self: return
	
	var dash_dir := Vector2.ZERO
	var player: Player = _get_player_in_vision()
	if player:
		dash_dir = context.global_position.direction_to(player.global_position)
		context.update_facing(player.global_position)
	else:
		dash_dir = Vector2(context.direction, 0)
	
	context.animation_player.play("dash")
	context.velocity = dash_dir * context.dash_speed
	
	await context.get_tree().create_timer(context.dash_length).timeout
	if context.state != self: return
	
	context.velocity = Vector2.UP * (context.chase_speed * 0.8)
	context.animation_player.play("idle")
	
	await context.get_tree().create_timer(0.2).timeout
	if context.state != self: return
	
	context.set_state($"../ChaseState")

func physics_update(_delta: float) -> void:
	pass

func exit() -> void:
	pass


func _get_player_in_vision() -> Player:
	for body in context.attack_area.get_overlapping_bodies():
		if body is Player:
			return body
	return null
