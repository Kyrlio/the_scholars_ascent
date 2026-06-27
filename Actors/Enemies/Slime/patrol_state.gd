extends EnemyState

var jump_timer: float = 0.0

func enter() -> void:
	_reset_timer()

func physics_update(delta: float) -> void:
	if _is_player_in_vision():
		context.set_state($"../ChaseState")
		return
	
	if context.is_on_floor():
		context.animation_player.play("idle")
		jump_timer -= delta
		
		if jump_timer <= 0.0:
			_jump()
	else:
		context.animation_player.play("jump")

func exit() -> void:
	pass

func _reset_timer() -> void:
	jump_timer = randf_range(1.5, 3.0)

func _is_player_in_vision() -> bool:
	for body in context.vision_area.get_overlapping_bodies():
		if body is Player:
			return true
	return false

func _jump() -> void:
	if randf() > 0.5 or context.wall_detection_ray.is_colliding() or not context.ledge_detection_ray.is_colliding():
		context.direction *= -1.0
		context.update_facing()
	
	context.velocity.y = context.jump_vertical_speed
	context.velocity.x = context.jump_horizontal_speed * context.direction
	context.apply_squish(0.5,1.3)
	
	_reset_timer()
