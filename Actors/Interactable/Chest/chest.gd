extends Area2D
class_name Chest

@export var item_content: ItemData
@export var chest_id: String = ""

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer

var is_opened: bool = false
var player_in_zone: Player = null


func _ready() -> void:
	if chest_id != "" and chest_id in GameState.opened_chests:
		is_opened = true
		animation_player.play("opened")
	else:
		animation_player.play("closed")
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("interact") and not is_opened:
		open_chest()
		get_viewport().set_input_as_handled()


func open_chest() -> void:
	is_opened = true
	
	if chest_id != "" and not chest_id in GameState.opened_chests:
		GameState.opened_chests.append(chest_id)
	
	animation_player.play("opening")
	
	if item_content != null:
		interact_animation_player.play("hide")
		GameEvents.emit_item_collected(item_content)
		player_in_zone.receive_item(item_content)
		
		await get_tree().create_timer(2).timeout
		player_in_zone.switch_state(Player.State.IDLE)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_opened:
		player_in_zone = body
		interact_animation_player.play("show")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_zone = null
		
		if not is_opened:
			interact_animation_player.play("hide")
