extends Node

var save_path = "user://save_game.dat"

func save_game(player_position: Vector2, current_health: int, total_gold: int) -> void:
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
		"gold": total_gold,
		"collected_items": items_save_data,
		"collected_charms": charms_paths,
		"equipped_charms": equipped_paths,
		"opened_chests": GameState.opened_chests,
		"collected_coins": GameState.collected_coins,
		"shop_stocks": GameState.shop_stocks
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
