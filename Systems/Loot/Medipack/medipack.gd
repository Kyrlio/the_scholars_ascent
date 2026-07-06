extends RigidBody2D
class_name Medipack

@export var heal_amount: int = 2

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var random_angle: float = randf_range(-PI * 0.8, -PI * 0.2)
	var random_speed: float = randf_range(50.0, 100.0)
	linear_velocity = Vector2.RIGHT.rotated(random_angle) * random_speed


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		var hp: HealthComponent = body.health_component
		
		if hp.current_health == hp.max_health:
			return
		
		animation_player.play("looted")
		hp.heal(heal_amount)
