extends EnemyState

var is_active: bool = false

func enter() -> void:
	is_active = true
	context.velocity.x = 0.0
	context.animation_player.play("charge_attack")
	
	await context.animation_player.animation_finished
	if not is_active or context.state != self: return
	
	context.animation_player.play("explosion")
	
	await context.animation_player.animation_finished
	if not is_active or context.state != self: return
	
	context.is_dead = true
	
	if context.enemy_id != "" and not context.enemy_id in GameState.defeated_enemies:
		GameState.defeated_enemies.append(context.enemy_id)
	
	if context.has_node("%Loots"):
		for loot in context.get_node("%Loots").get_children():
			loot.drop()
	
	context.queue_free()

func exit() -> void:
	is_active = false
	context.hitbox_component.set_deferred("monitoring", false)
	
