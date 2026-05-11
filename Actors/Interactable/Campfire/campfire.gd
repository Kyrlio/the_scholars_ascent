extends Area2D
class_name Campfire

@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var label_animation_player: AnimationPlayer = $Label/AnimationPlayer

var is_player_near: bool = false
var player: Player = null


func _ready() -> void:
	interact_sprite.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if is_player_near and event.is_action_pressed("interact"):
		rest_at_campfire()
		get_viewport().set_input_as_handled()


func rest_at_campfire() -> void:
	if player:
		interact_animation_player.play("pressed")
		
		player.switch_state(Player.State.REST)
		
		var hp_comp = player.health_component
		while hp_comp.current_health < hp_comp.max_health:
			hp_comp.current_health += 1
			await get_tree().create_timer(0.2).timeout
		
		SaveManager.save_game(player.global_position, player.get_current_health(), GameState.total_gold)
		
		print("Repos : Santé restaurée et partie sauvegardée !")
		spawn_save_label()
		
		await get_tree().create_timer(2.5).timeout
		player.switch_state(Player.State.IDLE)


func spawn_save_label() -> void:
	label_animation_player.play("show")


func play_default_animation() -> void:
	interact_animation_player.play("default")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_near = true
		player = body
		
		interact_animation_player.play("show")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_near = false
		
		interact_animation_player.play("hide")
