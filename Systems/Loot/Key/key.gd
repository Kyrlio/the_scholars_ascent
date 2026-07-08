extends RigidBody2D

const CHEST_KEY = preload("uid://fg4610ldofq0")

@export var key_id: String = ""
@export var apply_gravity: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var gold_value: int = 1

func _ready() -> void:
	if not apply_gravity:
		gravity_scale = 0.0
	
	if key_id == "":
		if owner != null and owner.scene_file_path != "":
			key_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
	else:
		key_id = str(get_path())
	
	if key_id != "" and key_id in GameState.collected_coins:
		queue_free()
		return


func _on_pick_up_area_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.emit_item_collected(CHEST_KEY, 1)
		animation_player.play("looted")
