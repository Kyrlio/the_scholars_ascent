extends Area2D
class_name Sign

@export var sign_text: String = "Press A to jump"

@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var label: Label = $TextVisuals/Label

var is_interacted: bool = false
var player_in_zone: Player = null


func _ready() -> void:
	label.text = sign_text
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("interact") and not is_interacted:
		interact_sign()
		get_viewport().set_input_as_handled()


func interact_sign() -> void:
	interacted(true)
	interact_animation_player.play("show_text")


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_interacted:
		player_in_zone = body
		interact_animation_player.play("show")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_zone = null
		
		if not is_interacted:
			interact_animation_player.play("hide")


func interacted(toggled: bool) -> void:
	is_interacted = toggled
