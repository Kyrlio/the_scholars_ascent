extends ItemData
class_name ActiveItem

@export var is_consumable: bool = true
@export var cooldown: float = 1.0


func use(player: Player) -> void:
	pass
