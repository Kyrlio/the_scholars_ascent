extends Node

signal engine_freeze_requested
signal camera_shake_requested(trauma_amount: float)
signal player_health_changed(current_health: int, max_health: int)
signal inventory_item_focused(item_data: ItemData)
signal gold_collected(amount: int)
signal item_collected(item: ItemData)
signal ability_unlocked(ability_name: String)
signal water_ammo_changed(current_water_ammo: int)


func emit_engine_freeze() -> void:
	engine_freeze_requested.emit()

func emit_camera_shake(trauma_amount: float) -> void:
	camera_shake_requested.emit(trauma_amount)

func emit_player_health_changed(current_health: int, max_health: int) -> void:
	player_health_changed.emit(current_health, max_health)

func emit_inventory_item_focused(item_data: ItemData) -> void:
	inventory_item_focused.emit(item_data)

func emit_gold_collected(amount: int) -> void:
	gold_collected.emit(amount)

func emit_item_collected(item: ItemData) -> void:
	item_collected.emit(item)

func emit_ability_unlocked(ability_name: String) -> void:
	ability_unlocked.emit(ability_name)

func emit_water_ammo_changed(current_water_ammo: int) -> void:
	water_ammo_changed.emit(current_water_ammo)
