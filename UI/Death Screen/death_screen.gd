extends CanvasLayer

@onready var reload_button: AnimatedButton = %ReloadButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	GameEvents.player_died.connect(_on_player_died)


func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	
	animation_player.play("play")
	show()
	await animation_player.animation_finished
	
	reload_button.grab_focus()
	get_tree().paused = true



func _on_reload_button_pressed() -> void:
	GameState.load_save_data()
	get_tree().paused = false
	get_tree().reload_current_scene()
	hide()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
