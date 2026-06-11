extends RigidBody2D

@export var coin_id: String = ""
@export var throw: bool = true
@export var apply_gravity: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var gold_value: int = 1

func _ready() -> void:
	if not apply_gravity:
		gravity_scale = 0.0
	
	if coin_id == "":
		if owner != null and owner.scene_file_path != "":
			coin_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			coin_id = str(get_path())
	
	if coin_id != "" and coin_id in GameState.collected_coins:
		queue_free()
		return
	
	if throw:
		var random_angle = randf_range(-PI * 0.8, -PI * 0.2)
		var random_speed = randf_range(150.0, 275.0)
		var random_direction = Vector2.RIGHT.rotated(random_angle)

		linear_velocity = random_direction * random_speed


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.emit_gold_collected(gold_value)
		
		if coin_id != "" and not coin_id in GameState.collected_coins:
			GameState.collected_coins.append(coin_id)
		
		animation_player.play("looted")
