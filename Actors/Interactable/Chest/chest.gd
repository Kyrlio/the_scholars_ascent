extends Area2D
class_name Chest

@export var chest_id: String = ""
@export var item_content: ItemData
@export var item_quantity: int = 1
@export var is_locked: bool = false
@export var required_key: ItemData = preload("uid://fg4610ldofq0")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var locked_sprite: Sprite2D = $LockedSprite
@onready var locked_animation_player: AnimationPlayer = $LockedSprite/LockedAnimationPlayer

var is_opened: bool = false
var player_in_zone: Player = null


func _ready() -> void:
	if is_locked:
		locked_sprite.show()
	else:
		locked_sprite.hide()
	
	if chest_id == "":
		if owner != null and owner.scene_file_path != "":
			chest_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			chest_id = str(get_path())
	
	if chest_id != "" and chest_id in GameState.opened_chests:
		is_opened = true
		animation_player.play("opened")
	else:
		animation_player.play("closed")
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("interact") and not is_opened:
		if is_locked:
			if has_required_key():
				consume_key()
				locked_animation_player.play("unlock")
				is_locked = false
			else:
				locked_animation_player.play("locked")
				print("You need a key")
		else:
			open_chest()
			get_viewport().set_input_as_handled()


func has_required_key() -> bool:
	if required_key == null:
		return false
	
	for slot in GameState.collected_items:
		if slot["item"] == required_key and slot["quantity"] > 0:
			return true
	
	return false


func consume_key() -> void:
	for slot in GameState.collected_items:
		if slot["item"] == required_key:
			slot["quantity"] -= 1
			if slot["quantity"] <= 0:
				GameState.collected_items.erase(slot)
			break


func open_chest() -> void:
	is_opened = true
	
	if chest_id != "" and not chest_id in GameState.opened_chests:
		GameState.opened_chests.append(chest_id)
	
	animation_player.play("opening")
	
	if item_content != null:
		interact_animation_player.play("hide")
		player_in_zone.receive_item(item_content)
		if item_content.item_name == "Gold":
			GameEvents.emit_gold_collected(item_quantity)
			await get_tree().create_timer(2).timeout
			player_in_zone.switch_state(Player.State.IDLE)
		else:
			GameEvents.emit_item_collected(item_content, item_quantity)
			if not item_content is CharmItem:
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
