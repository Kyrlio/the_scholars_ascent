extends Area2D
class_name Grass

@export var min_skew: float = -100
@export var max_skew: float = 100

@onready var animated_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D

func _ready() -> void:
	randomize()
	z_index = randi() % 2
	if animated_sprite and animated_sprite.material:
		animated_sprite.material.set("shader_parameter/offset", randi() % 3)
	animated_sprite.frame = randi() % 12


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and animated_sprite and animated_sprite.material:
		var direction = global_position.direction_to(body.global_position)
		var max_speed = 100.0
		if body is Player and body.stats:
			max_speed = body.stats.speed
		elif "speed" in body:
			max_speed = body.speed
		elif "walk_speed" in body:
			max_speed = body.walk_speed
		elif "jump_horizontal_speed" in body:
			max_speed = body.jump_horizontal_speed
		
		var skew = clamp(remap(body.velocity.length() * sign(-direction.x), -max_speed, max_speed, min_skew, max_skew), min_skew, max_skew)
		var tw: Tween = create_tween()
		tw.tween_property(animated_sprite.material, "shader_parameter/skew", skew, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(animated_sprite.material, "shader_parameter/skew", 0.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
