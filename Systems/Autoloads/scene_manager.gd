extends CanvasLayer

var scenes: Dictionary = {}
var current_scene: Node = null
var is_transitioning: bool = false

const ROOMS_FOLDER: String = "res://Levels/Rooms/"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	current_scene = get_tree().current_scene
	_load_all_rooms()


func _load_all_rooms() -> void:
	var dir := DirAccess.open(ROOMS_FOLDER)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".tscn") or file_name.ends_with(".tscn.remap"):
					
					# Clean the name to make a key (ex: "Room_1A.tscn" -> "Room_1A")
					var clean_name := file_name.replace(".remap", "").replace(".tscn", "")
					
					var file_path := ROOMS_FOLDER + file_name.replace(".remap", "")
					
					scenes[clean_name] = file_path
			file_name = dir.get_next()
		
		print("Salles chargées avec succès : ", scenes.keys())
	else:
		printerr("Erreur : Impossible de trouver le dossier " + ROOMS_FOLDER)


func change_room(room_name: String) -> void:
	if is_transitioning:
		return
	
	if not scenes.has(room_name):
		printerr("La salle " + room_name + " n'existe pas dans le dictionnaire !")
		return
	
	is_transitioning = true
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	var packed_scene = load(scenes[room_name])
	if packed_scene == null: return
	
	var new_room = packed_scene.instantiate()
	var game_scene = get_tree().current_scene
	var room_container = game_scene.get_node("LevelContainer/CurrentRoom")
	
	if room_container:
		if room_container.get_child_count() > 0:
			var old_room = room_container.get_child(0)
			#room_container.remove_child.call_deferred(old_room)
			old_room.queue_free()
		
		new_room.name = room_name
		room_container.add_child.call_deferred(new_room)
		
		var camera = game_scene.find_child("DynamicCamera", true, false)
		if camera:
			var room_tilemap = new_room.find_child("Ground", true, false)
			
			if room_tilemap:
				camera.update_limits(room_tilemap)
			else:
				printerr("Attention: Aucun TileMapLayer 'Ground' trouvé dans " + room_name)
		
		game_scene = get_tree().current_scene
		if game_scene.player and TeleportData.target_transition_name != "":
			var target_zone = new_room.find_child(TeleportData.target_transition_name, true, false)
			
			if target_zone and target_zone.has_node("SpawnPoint"):
				game_scene.player.global_position = target_zone.get_node("SpawnPoint").global_position
				game_scene.player.velocity = Vector2.ZERO
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	is_transitioning = false


func reload_current_room_for_rest(player: Node2D) -> void:
	if is_transitioning:
		return
	
	var game_scene = get_tree().current_scene
	var room_container = game_scene.get_node("LevelContainer/CurrentRoom")
	if not room_container or room_container.get_child_count() == 0:
		return
	
	is_transitioning = true
	var current_room = room_container.get_child(0)
	var room_scene_path = current_room.scene_file_path
	
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	var packed_scene = load(room_scene_path)
	if packed_scene == null:
		is_transitioning = false
		return
	
	var new_room = packed_scene.instantiate()
	current_room.queue_free()
	
	# Determine original dictionary key by matching scene path
	var room_name = current_room.name
	for key in scenes:
		if scenes[key] == room_scene_path:
			room_name = key
			break
	
	new_room.name = room_name
	room_container.add_child.call_deferred(new_room)
	
	var camera = game_scene.find_child("DynamicCamera", true, false)
	if camera:
		var room_tilemap = new_room.find_child("Ground", true, false)
		if room_tilemap:
			camera.update_limits(room_tilemap)
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	
	player.switch_state(player.State.IDLE)
	is_transitioning = false
