extends Node

var save_path = "user://save_game.dat"

func save_game(player_position: Vector2, current_health: int, total_gold: int) -> void:
	var items_paths: Array = []
	for item in GameState.collected_items:
		if item != null and item.resource_path != "":
			items_paths.append(item.resource_path)
	
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
		"collected_items": items_paths,
		"collected_charms": charms_paths,
		"equipped_charms": equipped_paths
		# Ajouter inventaire, etc...
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
