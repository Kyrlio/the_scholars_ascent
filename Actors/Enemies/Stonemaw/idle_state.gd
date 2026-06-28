extends EnemyState

var pop_timer: float = 0.0
var is_surfaced: bool = false
var is_transitioning: bool = false

func enter() -> void:
	context.velocity.x = 0.0
	is_surfaced = false
	is_transitioning = true
	
	if "is_invincible" in context.hurtbox_component:
		context.hurtbox_component.is_invincible = true
	
	if previous_state == $"../ChaseState":
		context.animation_player.play("idle_inside")
	else:
		context.animation_player.play("go_inside")
		await context.animation_player.animation_finished
		if context.state != self: return
	
	
	is_transitioning = false
	_reset_timer()

func exit() -> void:
	is_transitioning = false

func physics_update(delta: float) -> void:
	if _is_player_in_vision():
		context.set_state($"../ChaseState")
		return
	
	if is_transitioning:
		return
		
	pop_timer -= delta
	if pop_timer <= 0.0:
		_toggle_surface()

func _toggle_surface() -> void:
	is_transitioning = true
	is_surfaced = not is_surfaced
	
	if is_surfaced:
		print("surfaced")
		context.animation_player.play("go_outside")
		await context.animation_player.animation_finished
		if context.state != self: return
		context.animation_player.play("idle_outside")
		context.hurtbox_component.is_invincible = false
		pop_timer = randf_range(1.5, 3.0)
	else:
		print("inside")
		context.animation_player.play("go_inside")
		await context.animation_player.animation_finished
		if context.state != self: return
		context.animation_player.play("idle_inside")
		context.hurtbox_component.is_invincible = true
		pop_timer = randf_range(2.0, 4.0)
		
	is_transitioning = false

func _reset_timer() -> void:
	pop_timer = randf_range(2.0, 4.0)

func _is_player_in_vision() -> bool:
	for body in context.vision_area.get_overlapping_bodies():
		if body is Player:
			return true
	return false
