extends Control

@onready var new_game_button: AnimatedButton = %NewGameAnimatedButton
@onready var continue_button: AnimatedButton = %ContinueAnimatedButton
@onready var settings_button: AnimatedButton = %SettingsAnimatedButton
@onready var quit_button: AnimatedButton = %QuitAnimatedButton

@onready var confirmation_popup: Panel = %ConfirmationPopup
@onready var confirm_button: AnimatedButton = %ConfirmAnimatedButton
@onready var cancel_button: AnimatedButton = %CancelAnimatedButton


func _ready() -> void:
	confirmation_popup.hide()
	
	if FileAccess.file_exists(SaveManager.save_path):
		continue_button.disabled = false
		continue_button.grab_focus()
	else:
		continue_button.disabled = true
		new_game_button.grab_focus()


func start_new_game() -> void:
	GameState.reset_state()
	get_tree().change_scene_to_file("res://Levels/game.tscn")




func _on_new_game_animated_button_pressed() -> void:
	if FileAccess.file_exists(SaveManager.save_path):
		confirmation_popup.show()
		cancel_button.grab_focus()
	else:
		start_new_game()


func _on_continue_animated_button_pressed() -> void:
	GameState.load_save_data()
	get_tree().change_scene_to_file("res://Levels/game.tscn")


func _on_settings_animated_button_pressed() -> void:
	print("Ouvrir paramrte")


func _on_quit_animated_button_pressed() -> void:
	get_tree().quit()


func _on_cancel_animated_button_pressed() -> void:
	confirmation_popup.hide()
	new_game_button.grab_focus()


func _on_confirm_animated_button_pressed() -> void:
	DirAccess.remove_absolute(SaveManager.save_path)
	GameState.reset_state()
	start_new_game()
