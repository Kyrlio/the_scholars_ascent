extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const MAIN_MENU = preload("uid://c34md2nlrcm34")


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	
	animation_player.play("fade_in_out")


func _on_animation_finished(anim_name: String) -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)
