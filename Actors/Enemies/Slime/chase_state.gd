extends EnemyState

var jump_timer: float = 0.0
var lose_aggro_timer: float = 0.0
const AGGRO_TIME: float = 5.0

func enter() -> void:
	lose_aggro_timer = AGGRO_TIME
	jump_timer = 0.0

func physics_update(delta: float) -> void:
	var player: Player = _get_player_in_vision()
	
	if player:
		lose_aggro_timer = AGGRO_TIME
		
		if context.is_on_floor():
			context.animation_player.play("idle")
			jump_timer -= delta
			
			if jump_timer <= 0.0:
				context.direction = sign(player.global_position.x - context.global_position.x)
				context.update_facing()
				
				if not context.wall_detection_ray.is_colliding() and context.ledge_detection_ray.is_colliding():
					context.velocity.y = context.jump_vertical_speed
					context.velocity.x = (context.jump_horizontal_speed * 1.3) * context.direction
				
				jump_timer = randf_range(0.6, 1.0)
		else:
			context.animation_player.play("jump")
	else:
		lose_aggro_timer -= delta
		if lose_aggro_timer <= 0.0 and context.is_on_floor():
			context.set_state($"../PatrolState")


func _get_player_in_vision() -> Player:
	for body in context.vision_area.get_overlapping_bodies():
		if body is Player:
			return body
	return null
