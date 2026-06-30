extends Node2D

@export var intro_cutscene: DialogueResource

func _ready() -> void:
	var game: Game = get_tree().current_scene
	
	if game:
		game.loading_finished.connect(_on_loading_finished)


func _on_loading_finished() -> void:
	play_first_cutscene()


func play_first_cutscene() -> void:
	var camera: DynamicCamera = get_tree().get_first_node_in_group("camera")
	var player: Player = get_tree().get_first_node_in_group("player")
	var casting = [{
		"todd": player,
		"camera": camera,
		"room": self
	}]
	
	DialogueManager.show_dialogue_balloon(intro_cutscene, "start", casting)
