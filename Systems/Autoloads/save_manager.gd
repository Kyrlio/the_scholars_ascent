extends Node

var save_path = "user://save_game.dat"

func save_game(player_position: Vector2, current_health: int, total_gold: int) -> void:
	var current_room_name: String = ""
	var game_scene = get_tree().current_scene
	if game_scene and game_scene.has_node("LevelContainer/CurrentRoom"):
		var room_container = game_scene.get_node("LevelContainer/CurrentRoom")
		if room_container.get_child_count() > 0:
			var current_room = room_container.get_child(0)
			var room_scene_path = current_room.scene_file_path
			for key in SceneManager.scenes:
				if SceneManager.scenes[key] == room_scene_path:
					current_room_name = key
					break
			if current_room_name == "":
				current_room_name = current_room.name.to_snake_case()

	var items_save_data = []
	for slot_dict in GameState.collected_items:
		var item_res = slot_dict["item"]
		if item_res != null and item_res.resource_path != "":
			items_save_data.append({
				"path": item_res.resource_path,
				"quantity": slot_dict["quantity"]
			})
	
	var charms_paths: Array = []
	for charm in GameState.collected_charms:
		if charm != null and charm.resource_path != "":
			charms_paths.append(charm.resource_path)
	
	var equipped_paths: Array = []
	for charm in GameState.equipped_charms:
		if charm != null and charm.resource_path != "":
			equipped_paths.append(charm.resource_path)
	
	var save_data: Dictionary = {
		"player_pos_x": player_position.x,
		"player_pos_y": player_position.y,
		"health": current_health,
		"saved_room": current_room_name,
		"unlocked_max_health": GameState.unlocked_max_health,
		"collected_heart_containers": GameState.collected_heart_containers,
		"gold": total_gold,
		"collected_items": items_save_data,
		"collected_charms": charms_paths,
		"equipped_charms": equipped_paths,
		"opened_chests": GameState.opened_chests,
		"opened_star_doors": GameState.opened_star_doors,
		"collected_coins": GameState.collected_coins,
		"shop_stocks": GameState.shop_stocks,
		"activated_levers": GameState.activated_levers,
		"defeated_enemies": GameState.defeated_enemies,
		"completed_arenas": GameState.completed_arenas,
		"played_cutscenes": GameState.played_cutscenes,
		"unlocked_abilities": GameState.unlocked_abitilities
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file.store_var(save_data):
		print("Jeu sauvegardé avec succès !")
	else:
		printerr("Erreur avec la sauvegarde")


func load_game() -> Dictionary:
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		
		var loaded_data: Dictionary = file.get_var()
		return loaded_data
	else:
		return {}
