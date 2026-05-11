extends RigidBody2D

@export var gold_value: int = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var random_x = randf_range(-80.0, 80.0)
	var jump_force = -250.0
	
	linear_velocity = Vector2(random_x, jump_force)


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.emit_gold_collected(gold_value)
		animation_player.play("looted")
