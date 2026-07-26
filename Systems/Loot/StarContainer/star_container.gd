extends Area2D
class_name StarContainer

@export var container_id: String = ""
@export var item_data: ItemData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	container_id = GameState.get_unique_node_id(self, container_id)
	
	if container_id != "" and container_id in GameState.collected_star_containers:
		queue_free()
		return
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if container_id != "" and not container_id in GameState.collected_star_containers:
			GameState.collected_star_containers.append(container_id)
		
		GameEvents.emit_item_collected(item_data, 1)
		
		animated_sprite.play("recolted")
		set_deferred("monitoring", false)
		await animated_sprite.animation_finished
		queue_free.call_deferred()
		
		GameEvents.emit_show_ability_popup("Star", "You collected a Star ! You need to find 5 of these to open the Archmage's door.", item_data.icon)
