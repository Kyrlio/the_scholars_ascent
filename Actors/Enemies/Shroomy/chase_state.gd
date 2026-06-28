extends EnemyState

const AGGRO_TIME: float = 5.0

var lose_aggro_timer: float = 0.0


func enter() -> void:
	context.animation_player.play("walk")
	lose_aggro_timer = AGGRO_TIME


func physics_update(delta: float) -> void:
	if not is_instance_valid(context.player):
		var player_node = context.get_tree().get_first_node_in_group("player")
		if is_instance_valid(player_node):
			context.player = player_node
		else:
			context.set_state($"../PatrolState")
			return
	
	var is_player_spotted: bool = context.vision_area.overlaps_body(context.player)
	
	if is_player_spotted:
		lose_aggro_timer = AGGRO_TIME
		
		var is_player_in_attack_range: bool = context.attack_area.overlaps_body(context.player)
		if is_player_in_attack_range:
			context.set_state($"../AttackState")
			return
	else:
		lose_aggro_timer -= delta
		if lose_aggro_timer <= 0.0:
			context.player = null
			context.set_state($"../PatrolState")
			return
	
	context.update_facing()
	
	var is_blocked: bool = context.wall_detection_ray.is_colliding() or not context.ledge_detection_ray.is_colliding()
	
	if is_blocked:
		context.velocity.x = 0.0
		context.animation_player.play("idle")
	else:
		context.velocity.x = context.chase_speed * context.direction
		context.animation_player.play("walk")


func exit() -> void:
	pass
