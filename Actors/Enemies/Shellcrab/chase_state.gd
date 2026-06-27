extends EnemyState

const AGGRO_TIME: float = 2.0

var lose_aggro_timer: float = 0.0


func enter() -> void:
	context.animation_player.play("walk")
	context.hurtbox_component.toggle_invincibility(false)
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
	var is_player_in_melee: bool = context.melee_area.overlaps_body(context.player)
	var is_player_in_defense_range: bool = context.defense_area.overlaps_body(context.player)
	
	if is_player_in_defense_range:
		context.set_state($"../DefenseState")
		return
	elif is_player_spotted:
		lose_aggro_timer = AGGRO_TIME
	else:
		lose_aggro_timer -= delta
		if lose_aggro_timer <= 0.0:
			context.player = null
			context.set_state($"../PatrolState")
			return
	
	context.direction = sign(context.player.global_position.x - context.global_position.x)
	context.update_facing()
	
	if is_player_in_melee and context.attack_timer.is_stopped():
		context.set_state($"../AttackState")
		return
	
	context.velocity.x = context.chase_speed * context.direction
	context.update_direction()


func exit() -> void:
	pass
