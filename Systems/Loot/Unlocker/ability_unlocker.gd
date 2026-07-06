extends Area2D
class_name AbilityUnlocker

@export var abilities_to_unlock: Array[String] = [] ## Example: "sword", "pogo"

@export var min_skew: float = -200
@export var max_skew: float = 200

@export_group("Popup Informations")
@export var popup_title: String = ""
@export_multiline var popup_desc: String = ""
@export var popiup_icon_text: Texture2D

@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $Area2D/Marker2D/AnimatedSprite2D

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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and animated_sprite and animated_sprite.material:
		var direction = global_position.direction_to(body.global_position)
		var max_speed = 100.0
		if body is Player and body.stats:
			max_speed = body.stats.speed
		elif "speed" in body:
			max_speed = body.speed
		elif "walk_speed" in body:
			max_speed = body.walk_speed
		elif "jump_horizontal_speed" in body:
			max_speed = body.jump_horizontal_speed
		
		var skew = clamp(remap(body.velocity.length() * sign(-direction.x), -max_speed, max_speed, min_skew, max_skew), min_skew, max_skew)
		var tw: Tween = create_tween()
		tw.tween_property(animated_sprite.material, "shader_parameter/skew", skew, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(animated_sprite.material, "shader_parameter/skew", 0.0, 3.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
