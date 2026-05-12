extends Button
class_name AnimatedSlot

@export var item_data: ItemData:
	set(value):
		item_data = value
		if is_node_ready():
			update_visuals()

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var icon_sprite: Sprite2D = $IconSprite

var tween: Tween

func _ready() -> void:
	nine_patch_rect.hide()
	
	update_visuals()
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)


func update_visuals() -> void:
	if item_data != null:
		icon_sprite.texture = item_data.icon
		icon_sprite.show()
	else:
		icon_sprite.hide()


func _on_focus_entered() -> void:
	nine_patch_rect.show()
	animation_player.play("default")
	
	GameEvents.emit_inventory_item_focused(item_data)
	
	if tween != null:
		tween.stop()
	tween = create_tween()
	tween.tween_property(icon_sprite, "scale", Vector2(1.2, 1.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_focus_exited() -> void:
	nine_patch_rect.hide()
	animation_player.stop()
	
	if tween != null:
		tween.stop()
	tween = create_tween()
	tween.tween_property(icon_sprite, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
