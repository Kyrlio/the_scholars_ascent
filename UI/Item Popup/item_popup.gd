extends PanelContainer
class_name ItemPopup


@onready var icon_rect: TextureRect = %IconRect
@onready var title_label: Label = %TitleLabel
@onready var quantity_label: Label = %QuantityLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func setup(item: ItemData, quantity: int) -> void:
	icon_rect.texture = item.icon
	title_label.text = item.item_name
	
	if quantity > 1:
		quantity_label.text = "x" + str(quantity)
		quantity_label.show()
	else:
		quantity_label.hide()


func _ready() -> void:
	hide()

func play_show() -> void:
	animation_player.play("show")

func play_hide() -> void:
	animation_player.play("hide")
