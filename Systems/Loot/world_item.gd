extends RigidBody2D
class_name WorldItem

@export var item_data: ItemData

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var random_angle = randf_range(-PI * 0.8, -PI * 0.2)
	var random_speed = randf_range(150.0, 275.0)
	var random_direction = Vector2.RIGHT.rotated(random_angle)

	linear_velocity = random_direction * random_speed
	
	if "item_data" in self and item_data and item_data.icon:
		sprite.texture = item_data.icon

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.emit_item_collected(item_data)
		animation_player.play("looted")
