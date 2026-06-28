extends EnemyState

var action_timer: float = 0.0
var is_idling: bool = false

func enter() -> void:
	context.vision_area.body_entered.connect(_on_player_spotted)
	_randomize_action()


func exit() -> void:
	if context.vision_area.body_entered.is_connected(_on_player_spotted):
		context.vision_area.body_entered.disconnect(_on_player_spotted)


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
	
	var is_player_in_attack_range: bool = context.attack_area.overlaps_body(context.player)
	if is_player_in_attack_range:
		context.velocity.x = 0.0
		context.set_state($"../AttackState")
		return
	
	if not is_idling:
		context.velocity.x = context.speed * context.direction
		context.update_direction()
	else:
		context.velocity.x = 0.0


func _on_player_spotted(body: Node2D) -> void:
	if body is Player:
		context.player = body
		context.set_state($"../ChaseState")


func _randomize_action() -> void:
	is_idling = randf() > 0.5
	action_timer = randf_range(1.5, 3.5)
	
	if is_idling:
		context.animation_player.play("idle")
	else:
		if randf() > 0.5:
			context.direction *= -1.0
			context.visuals.scale.x = context.direction
		context.animation_player.play("walk")
