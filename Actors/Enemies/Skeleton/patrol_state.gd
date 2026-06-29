extends EnemyState

var action_timer: float = 0.0
var is_idling: bool = true

func enter() -> void:
	_randomize_action()

func physics_update(delta: float) -> void:
	if not is_instance_valid(context.player):
		var player_node = context.get_tree().get_first_node_in_group("player")
		if is_instance_valid(player_node):
			context.player = player_node
		else:
			context.set_state($"../PatrolState")
			return
	
	action_timer -= delta
	if action_timer <= 0.0:
		_randomize_action()
	
	var is_player_in_vision: bool = context.vision_area.overlaps_body(context.player)
	if is_player_in_vision:
		if context.attack_timer.is_stopped():
			context.set_state($"../AttackState")
		else:
			context.velocity.x = 0.0
			context.direction = sign(context.player.global_position.x - context.global_position.x)
			context.update_facing()
			context.animation_player.play("idle")
		return
	
	var is_player_in_flee_range: bool = context.flee_area.overlaps_body(context.player)
	if is_player_in_flee_range:
		context.set_state($"../FleeState")
		return
	
	if not is_idling:
		context.velocity.x = context.walk_speed * context.direction
		context.update_direction()
	else:
		context.velocity.x = 0.0


func _randomize_action() -> void:
	is_idling = randf() > 0.2
	action_timer = randf_range(1.5, 4.0)
	
	if is_idling:
		context.animation_player.play("idle")
	else:
		if randf() > 0.5:
			context.direction *= -1.0
			context.visuals.scale.x = context.direction
		context.animation_player.play("walk")
