extends CanvasLayer

@onready var title_label: Label = %TitleLabel
@onready var icon_rect: TextureRect = %IconRect
@onready var desc_label: RichTextLabel = %DescLabel
@onready var panel: Panel = $Panel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var show_item_animation_finished: bool = false

func _ready() -> void:
	hide()
	animation_player.play("hide")
	GameEvents.show_ability_popup.connect(_on_show_popup)
	GameEvents.show_item_player_animation_finished.connect(func(): show_item_animation_finished = true)


func _on_show_popup(title: String, desc: String, icon_text: Texture2D) -> void:
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if player != null and player.current_state == Player.State.SHOW_ITEM:
		show_item_animation_finished = false
		await GameEvents.show_item_player_animation_finished
	
	title_label.text = title
	desc_label.text = desc
	icon_rect.texture = icon_text
	
	get_tree().paused = true
	
	show()
	animation_player.play("show")
	reset_physics_interpolation()


func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_accept") or event.is_action_pressed("interact")):
		get_viewport().set_input_as_handled()
		close_popup()


func close_popup() -> void:
	animation_player.play("hide")
	await animation_player.animation_finished
	hide()
	get_tree().paused = false
