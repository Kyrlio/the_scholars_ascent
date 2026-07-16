extends ActiveItem
class_name ShieldItem

@export var max_shield_hp: int = 3


func _init() -> void:
	is_consumable = false


func use(player: Player) -> void:
	if player.current_state != Player.State.SHIELD:
		player.current_shield_item = self
		player.shield_hp = max_shield_hp
		player.switch_state(Player.State.SHIELD)
