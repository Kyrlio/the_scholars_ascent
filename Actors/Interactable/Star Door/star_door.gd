extends Area2D
class_name StarDoor

@export_group("Requirements")
@export var required_star: ItemData
@export var required_amount: int = 5

@export_group("Destination")
@export var target_room: String = "BossRoom"
@export var target_zone_name: String = "BossSpawnPoint"

@export_group("Persistence")
@export var door_id: String = ""

@onready var door_animation_player: AnimationPlayer = $DoorAnimationPlayer
@onready var interact_sprite: Sprite2D = $InteractSprite
@onready var stars_container: Node2D = $StarsContainer
@onready var interact_sprite_animation_player: AnimationPlayer = $InteractSprite/InteractSpriteAnimationPlayer

var is_opened: bool = false
var is_animating: bool = false
var player_in_zone: Player = null

func _ready() -> void:
	interact_sprite.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if door_id == "":
		if owner != null and owner.scene_file_path != "":
			door_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			door_id = str(get_path())
	
	if door_id != "" and door_id in GameState.opened_star_doors:
		is_opened = true
		stars_container.hide()
		door_animation_player.play("open")


func _unhandled_input(event: InputEvent) -> void:
	if player_in_zone and event.is_action_pressed("interact") and is_opened:
		interact_sprite_animation_player.play("pressed")
		get_viewport().set_input_as_handled()
		teleport_to_boss()


func get_player_star_count() -> int:
	if required_star == null:
		return 0
	for slot in GameState.collected_items:
		if slot["item"] == required_star:
			return slot["quantity"]
	return 0


func open_door() -> void:
	is_opened = true
	interact_sprite.hide()
	
	if door_id != "" and not door_id in GameState.opened_star_doors:
		GameState.opened_star_doors.append(door_id)
	
	door_animation_player.play("opening")
	await door_animation_player.animation_finished


func teleport_to_boss() -> void:
	TeleportData.target_transition_name = target_zone_name
	SceneManager.change_room(target_room)


func _play_star_sequence(player: Player) -> void:
	is_animating = true
	var star_count = get_player_star_count()
	
	var stars_to_show: int = min(star_count, required_amount)
	var star_slots := stars_container.get_children()
	var moving_stars: Array[Sprite2D] = []
	
	for i in range(stars_to_show):
		var temp_star = Sprite2D.new()
		temp_star.texture = required_star.icon
		temp_star.top_level = true
		temp_star.global_position = player.global_position
		add_child(temp_star)
		reset_physics_interpolation()
		moving_stars.append(temp_star)
		
		var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(temp_star, "global_position", star_slots[i].global_position, 0.4)
		
		await get_tree().create_timer(0.2).timeout
	
	if stars_to_show > 0:
		await get_tree().create_timer(0.5).timeout
	
	if star_count >= required_amount:
		_consume_stars()
		var fade_tween = create_tween().set_parallel()
		for s in moving_stars:
			fade_tween.tween_property(s, "scale", Vector2.ZERO, 0.4)
			fade_tween.tween_property(s, "modulate:a", 0.0, 0.4)
		for sprite in stars_container.get_children():
			fade_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.4)
			fade_tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		
		await fade_tween.finished
		
		stars_container.hide()
		
		for s in moving_stars:
			s.queue_free()
		
		door_animation_player.play("opening")
		await door_animation_player.animation_finished
		
		is_opened = true
		is_animating = false
		
		if door_id != "" and not door_id in GameState.opened_star_doors:
			GameState.opened_star_doors.append(door_id)
		
		if player_in_zone != null:
			interact_sprite_animation_player.play("show")
		
	else:
		for i in range(moving_stars.size()):
			var s = moving_stars[i]
			var return_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			
			var target_pos = player_in_zone.global_position if player_in_zone else player.global_position
			return_tween.tween_property(s, "global_position", target_pos, 0.4)
			return_tween.tween_property(s, "scale", Vector2.ZERO, 0.4)
			
			await get_tree().create_timer(0.2).timeout
		
		await get_tree().create_timer(0.4).timeout
		
		for s in moving_stars:
			s.queue_free()
		
		is_animating = false


func _consume_stars() -> void:
	for slot in GameState.collected_items:
		if slot["item"] == required_star:
			slot["quantity"] -= required_amount
			if slot["quantity"] <= 0:
				GameState.collected_items.erase(slot)
			break


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_zone = body
		if is_opened:
			interact_sprite_animation_player.play("show")
		elif not is_animating:
			_play_star_sequence(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_zone = null
		if is_opened:
			interact_sprite_animation_player.play("hide")
