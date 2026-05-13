extends Area2D
class_name Chuck

@export var inventory: Array[ShopItem] = []

@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var shop_menu: ShopMenu = $ShopMenu

var player_in_zone: Player = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_zone != null:
		if not shop_menu.visible:
			open_shop()


func open_shop() -> void:
	shop_menu.open_shop(inventory)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_zone = body
		interact_animation_player.play("show")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_zone = null
		interact_animation_player.play("hide")
		shop_menu.close_shop()
