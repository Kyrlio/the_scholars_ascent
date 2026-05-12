extends RigidBody2D
class_name WorldItem

@export var item_data: ItemData

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	var random_x: float = randf_range(-80.0, 80.0)
	var jump_force: float = -250.0
	linear_velocity = Vector2(random_x, jump_force)
	
	if item_data and item_data.icon:
		sprite.texture = item_data.icon

func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.emit_item_collected(item_data)
		
		queue_free()
