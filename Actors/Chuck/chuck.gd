extends Area2D
class_name Chuck

@export var inventory: Array[ShopItem] = []
@export var dialogue_resource: DialogueResource

@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var shop_menu: ShopMenu = $ShopMenu
@onready var visuals: Node2D = $Visuals

var player_in_zone: Player = null

# Dialogue
var first_met: bool = false


func _ready() -> void:
	GameEvents.shop_opened.connect(open_shop)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if player_in_zone:
		visuals.scale.x = sign(player_in_zone.global_position.x - global_position.x)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_zone != null:
		if not shop_menu.visible:
			if not dialogue_resource:
				open_shop()
				get_viewport().set_input_as_handled()
			else:
				DialogueManager.show_dialogue_balloon(dialogue_resource, "chuck_rencontre", [self])
				get_viewport().set_input_as_handled()


func open_shop() -> void:
	GameState.is_shop_active = true
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
