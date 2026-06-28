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
	
	context.queue_free()

func exit() -> void:
	is_active = false
	context.hitbox_component.set_deferred("monitoring", false)
