extends RigidBody2D

@export var gold_value: int = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var random_angle = randf_range(-PI * 0.8, -PI * 0.2)
	var random_speed = randf_range(150.0, 275.0)
	var random_direction = Vector2.RIGHT.rotated(random_angle)

	linear_velocity = random_direction * random_speed


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.emit_gold_collected(gold_value)
		animation_player.play("looted")
