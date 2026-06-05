extends Area2D
class_name Sign

@export var sign_text: String = "Press A to jump"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $TextVisuals/Label

var player_in_zone: Player = null


func _ready() -> void:
	label.text = sign_text
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_zone = body
		animation_player.play("show_text")
