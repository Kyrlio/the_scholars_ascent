extends Area2D
class_name StarContainer

@export var container_id: String = ""
@export var item_data: ItemData

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if container_id == "":
		if owner != null and owner.scene_file_path != "":
			container_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			container_id = str(get_path())
	
	if container_id != "" and container_id in GameState.collected_heart_containers:
		queue_free()
		return
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameEvents.emit_item_collected(item_data, 1)
		
		animated_sprite.play("recolted")
		set_deferred("monitoring", false)
		await animated_sprite.animation_finished
		queue_free.call_deferred()
		
		GameEvents.emit_show_ability_popup("Star", "You collected a Star ! You need to find 5 of these to open the Archmage's door.", item_data.icon)
