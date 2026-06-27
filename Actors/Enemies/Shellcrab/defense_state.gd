extends EnemyState


func enter() -> void:
	context.velocity.x = 0.0
	context.animation_player.play("defense_in")
	
	await context.animation_player.animation_finished
	
	context.hurtbox_component.toggle_invincibility(true)

func physics_update(_delta: float) -> void:
	context.velocity.x = 0.0
	
	if not is_instance_valid(context.player):
		var player_node = context.get_tree().get_first_node_in_group("player")
		if is_instance_valid(player_node):
			context.player = player_node
		else:
			context.set_state($"../PatrolState")
			return
	
	var is_player_in_range: bool = context.defense_area.overlaps_body(context.player)
	
	if not is_player_in_range:
		context.set_state($"../ChaseState")
		return

func exit() -> void:
	context.animation_player.play("defense_out")
	context.hurtbox_component.toggle_invincibility(false)
