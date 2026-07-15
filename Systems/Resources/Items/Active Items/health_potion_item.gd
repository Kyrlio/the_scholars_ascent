extends ActiveItem
class_name HealthPotionItem

@export var heal_amount: int = 2

func use(player: Player) -> void:
	var hp: HealthComponent = player.health_component
	hp.heal(heal_amount)
	# TODO: Juice
