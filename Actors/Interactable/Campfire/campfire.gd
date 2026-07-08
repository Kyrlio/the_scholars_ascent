extends Area2D
class_name Campfire

@export_group("Light Flicker")
@export var noise_speed: float = 75.0
@export var energy_flicker_amount: float = 0.5
@export var scale_flicker_amount: float = 0.15
@export var base_energy: float = 0.75

@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var interact_animation_player: AnimationPlayer = $InteractSprite/AnimationPlayer
@onready var label_animation_player: AnimationPlayer = $Label/AnimationPlayer
@onready var campfire_light: PointLight2D = $CampfireLight

var is_player_near: bool = false
var player: Player = null
var noise: FastNoiseLite = FastNoiseLite.new()
var time_passed: float = 0.0

func _ready() -> void:
	interact_sprite.hide()
	
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.05
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	time_passed += delta * noise_speed
	var noise_value = noise.get_noise_1d(time_passed)
	campfire_light.energy = base_energy + (noise_value * energy_flicker_amount)
	campfire_light.texture_scale = 1.0 + (noise_value * scale_flicker_amount)


func _unhandled_input(event: InputEvent) -> void:
	if is_player_near and event.is_action_pressed("interact"):
		rest_at_campfire()
		get_viewport().set_input_as_handled()


func rest_at_campfire() -> void:
	if player:
		interact_animation_player.play("pressed")
		
		player.switch_state(Player.State.REST)
		player._update_facing_direction(sign(global_position.x - player.global_position.x))
		
		var hp_comp = player.health_component
		while hp_comp.current_health < hp_comp.max_health:
			hp_comp.current_health += 1
			await get_tree().create_timer(0.2).timeout
		
		GameState.defeated_enemies.clear() # Respawn enemies
		GameState.destroyed_props.clear() # Respawn destructible props
		
		SaveManager.save_game(player.global_position, player.get_current_health(), GameState.total_gold)
		
		print("Repos : Santé restaurée et partie sauvegardée !")
		spawn_save_label()
		
		await get_tree().create_timer(2.5).timeout
		SceneManager.reload_current_room_for_rest(player)


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
