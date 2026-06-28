extends EnemyState


func enter() -> void:
	context.velocity.x = 0.0
	
	context.hitbox_component.set_deferred("monitoring", false)
	context.hurtbox_component.set_deferred("monitoring", false)
	
	context.animation_player.play("death")
	
	if context.enemy_id != "" and not context.enemy_id in GameState.defeated_enemies:
		GameState.defeated_enemies.append(context.enemy_id)
	
	await context.animation_player.animation_finished
	
	if context.has_node("%Loots"):
		for loot in context.get_node("%Loots").get_children():
			loot.drop()
	
	context.queue_free()
