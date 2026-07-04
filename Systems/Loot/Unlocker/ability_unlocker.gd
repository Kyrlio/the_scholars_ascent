extends Area2D
class_name AbilityUnlocker

@export var abilities_to_unlock: Array[String] = [] ## Example: "sword", "pogo"

@export_group("Popup Informations")
@export var popup_title: String = ""
@export_multiline var popup_desc: String = ""
@export var popiup_icon_text: Texture2D

@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer

var player_in_zone: Player = null
var popup_emitted: bool = false

func _ready() -> void:
	interact_sprite.hide()
	
	if player_missing_ability():
		if not body_entered.is_connected(_on_body_entered):
			body_entered.connect(_on_body_entered)
		if not body_exited.is_connected(_on_body_exited):
			body_exited.connect(_on_body_exited)


func player_missing_ability() -> bool:
	for ability in abilities_to_unlock:
		if not GameState.has_ability(ability):
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("interact") and player_missing_ability():
		pick_abilities()
		get_viewport().set_input_as_handled()


func pick_abilities() -> void:
	for ability in abilities_to_unlock:
		if not GameState.has_ability(ability):
			GameState.unlocked_abitilities.append(ability)
			GameEvents.emit_ability_unlocked(ability)
			print("Compétence débloquée : ", ability)
			
			if not popup_emitted:
				if player_in_zone != null:
					player_in_zone.play_show_item_animation(popiup_icon_text)
				GameEvents.emit_show_ability_popup(popup_title, popup_desc, popiup_icon_text)
				popup_emitted = true
			
			# to show a popup
			#GameEvents.emit_ability_unlocked(ability)
			
			set_deferred("monitoring", false)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interact_sprite.show()
		animation_player.play("show")
		player_in_zone = body


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_zone = null
		animation_player.play("hide") 
