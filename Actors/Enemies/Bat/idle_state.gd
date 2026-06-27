extends EnemyState

func enter() -> void:
	context.velocity = Vector2.ZERO
	context.animation_player.play("idle")
	
	context.hitbox_component.set_deferred("monitoring", true)
	context.hitbox_component.set_deferred("monitorable", true)
	context.hurtbox_component.set_deferred("monitoring", true)

func physics_update(_delta: float) -> void:
	for body in context.vision_area.get_overlapping_bodies():
		if body is Player:
			context.set_state($"../ChaseState")
			return

func exit() -> void:
	pass
