extends Area2D
class_name HeartContainer

@export var container_id: String = ""

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if container_id == "":
		if owner != null and owner.scene_file_path != "":
			container_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			container_id = str(get_path())
	
	#print(container_id)
	#print(GameState.collected_heart_containers)
	
	if container_id != "" and container_id in GameState.collected_heart_containers:
		queue_free()
		return
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.unlocked_max_health += 2
		GameState.collected_heart_containers.append(container_id)
		
		if body.health_component:
			body.health_component.set_max_health(GameState.unlocked_max_health, true)
		
		print("Max health increased : ", GameState.unlocked_max_health)
		
		animated_sprite.play("recolted")
		set_deferred("monitoring", false)
		await animated_sprite.animation_finished
		queue_free.call_deferred()
