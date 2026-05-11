extends Node

var save_path = "user://save_game.dat"

func save_game(player_position: Vector2, current_health: int, total_gold: int) -> void:
	var save_data: Dictionary = {
		"player_pos_x": player_position.x,
		"player_pos_y": player_position.y,
		"health": current_health,
		"gold": total_gold
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
