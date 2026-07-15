extends Node

signal engine_freeze_requested
signal camera_shake_requested(trauma_amount: float)
signal player_health_changed(current_health: int, max_health: int)
signal player_died
signal inventory_item_focused(item_data: ItemData)
signal gold_collected(amount: int)
signal item_collected(item: ItemData, quantity: int)
signal ability_unlocked(ability_name: String)
signal water_ammo_changed(current_water_ammo: int)
signal shop_opened
signal show_ability_popup(title: String, desc: String, texture: Texture2D)
signal show_item_player_animation_finished
signal equipment_updated(is_lb: bool, item: ActiveItem, quantity: int)


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

func emit_item_collected(item: ItemData, quantity: int = 1) -> void:
	item_collected.emit(item, quantity)

func emit_ability_unlocked(ability_name: String) -> void:
	ability_unlocked.emit(ability_name)

func emit_water_ammo_changed(current_water_ammo: int) -> void:
	water_ammo_changed.emit(current_water_ammo)

func emit_player_died() -> void:
	player_died.emit()

func emit_show_ability_popup(title: String, desc: String, icon_texture: Texture2D) -> void:
	show_ability_popup.emit(title, desc, icon_texture)

func emit_show_item_player_animation_finished() -> void:
	show_item_player_animation_finished.emit()

func emit_equipment_updated(is_lb: bool, item: ActiveItem, quantity: int) -> void:
	equipment_updated.emit(is_lb, item, quantity)
