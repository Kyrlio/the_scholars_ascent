extends CanvasLayer

@onready var tabs = [%InventoryTab, %CharmsTab, %SettingsTab]
@onready var header_icons = [%Tab1, %Tab2, %Tab3]

@onready var tab_content: Control = %TabContent
@onready var tab_name_label: Label = $TabNameLabel
@onready var quit_button: Button = %QuitButton
@onready var slot_grid: GridContainer = %SlotGrid
@onready var item_name: Label = %ItemName
@onready var item_description: RichTextLabel = %ItemDescription

@onready var equipped_charms_grid: GridContainer = %EquippedCharmsGrid
@onready var charm_slot_grid: GridContainer = %CharmSlotGrid
@onready var charm_name: Label = %CharmName
@onready var charm_description: RichTextLabel = %CharmDescription

@onready var equipped_slots: Array = equipped_charms_grid.get_children()
@onready var available_slots: Array = charm_slot_grid.get_children()
@onready var inventory_slots: Array = slot_grid.get_children()

@onready var lt: TextureRect = %LT
@onready var rt: TextureRect = %RT

const LT_PRESSED = preload("uid://d0coissingdcp")
const LT_UNPRESSED = preload("uid://be1f4odnvb34d")
const RT_PRESSED = preload("uid://i6b7dxnu031v")
const RT_UNPRESSED = preload("uid://01bxmtksirhm")


var current_tab: int = 0
var is_menu_open: bool = false
var header_tween: Tween
var slot_tween: Tween
var focused_slot: AnimatedSlot = null


func _ready() -> void:	
	hide()
	update_tabs()
	
	lt.texture = LT_UNPRESSED
	rt.texture = RT_UNPRESSED
	
	GameEvents.inventory_item_focused.connect(update_item_info)
	
	for slot in equipped_slots:
		slot.focus_entered.connect(_on_slot_focused.bind(slot))
		slot.pressed.connect(_on_equipped_slot_pressed.bind(slot))
	
	for slot in available_slots:
		slot.focus_entered.connect(_on_slot_focused.bind(slot))
		slot.pressed.connect(_on_available_slot_pressed.bind(slot))
	
	for slot in inventory_slots:
		slot.focus_entered.connect(_on_inventory_slot_focused.bind(slot))


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_menu") or Input.is_action_just_pressed("escape"):
		toggle_menu()
		get_viewport().set_input_as_handled()
		return
	
	if not is_menu_open:
		return
	
	if Input.is_action_just_pressed("tab_right"):
		current_tab = (current_tab + 1) % tabs.size()
		update_tabs()
		get_viewport().set_input_as_handled()
		return
	
	elif Input.is_action_just_pressed("tab_left"):
		current_tab = (current_tab - 1 + tabs.size()) % tabs.size()
		update_tabs()
		get_viewport().set_input_as_handled()
		return
	
	elif Input.is_action_just_pressed("ui_cancel"):
		toggle_menu()
		get_viewport().set_input_as_handled()
		return
	
	# Handle custom actions (A / Y) on focused slots
	if focused_slot != null and focused_slot.item_data != null:
		if current_tab == 0: # Inventory
			if Input.is_action_just_pressed("interact"):
				if focused_slot.item_data is ActiveItem:
					print("[GameMenu] Using active item: ", focused_slot.item_data.item_name)
					use_active_item(focused_slot.item_data)
					get_viewport().set_input_as_handled()
				else:
					print("[GameMenu] Item is not an ActiveItem: ", focused_slot.item_data.item_name)
			elif Input.is_action_just_pressed("jump"):
				print("[GameMenu] Action A on item: ", focused_slot.item_data.item_name)
				# Put here any custom equipping/action logic for general items
				get_viewport().set_input_as_handled()
		
		elif current_tab == 1: # Charms
			if Input.is_action_just_pressed("jump"):
				print("[GameMenu] Action A on charm: ", focused_slot.item_data.item_name)
				if focused_slot in available_slots:
					_on_available_slot_pressed(focused_slot)
				elif focused_slot in equipped_slots:
					_on_equipped_slot_pressed(focused_slot)
				get_viewport().set_input_as_handled()
	
	update_buttons_textures()


func update_buttons_textures() -> void:
	if Input.is_action_pressed("tab_right"):
		rt.texture = RT_PRESSED
	else:
		rt.texture = RT_UNPRESSED
	
	if Input.is_action_pressed("tab_left"):
		lt.texture = LT_PRESSED
	else:
		lt.texture = LT_UNPRESSED


func update_header_animation() -> void:
	if header_tween and header_tween.is_running():
		header_tween.kill()
	
	header_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	for i in range(header_icons.size()):
		var icon = header_icons[i]
		
		icon.pivot_offset = icon.size / 2.0
		
		if i == current_tab:
			header_tween.tween_property(icon, "modulate", Color.WHITE, 0.2)
			header_tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.2)
		else:
			var gray_color = Color(0.51, 0.62, 0.65, 1.0)
			header_tween.tween_property(icon, "modulate", gray_color, 0.2)
			header_tween.tween_property(icon, "scale", Vector2(0.9, 0.9), 0.2)


func toggle_menu() -> void:
	if get_tree().paused and not is_menu_open:
		return
	
	is_menu_open = !is_menu_open
	visible = is_menu_open
	
	Input.action_release("roll")
	await get_tree().process_frame
	await get_tree().process_frame
	
	get_tree().paused = is_menu_open
	
	if is_menu_open:
		update_charms_tab()
		update_inventory_tab()
		update_tabs()


func update_inventory_tab() -> void:
	for i in range(inventory_slots.size()):
		var slot: AnimatedSlot = inventory_slots[i]
		
		if i < GameState.collected_items.size():
			var slot_dict: Dictionary = GameState.collected_items[i]
			
			slot.quantity = slot_dict["quantity"]
			slot.item_data = slot_dict["item"]
		else:
			slot.quantity = 0
			slot.item_data = null


func update_tabs() -> void:
	focused_slot = null
	for i in range(tabs.size()):
		tabs[i].visible = (i == current_tab)
	
	update_tab_name()
	
	match current_tab:
		0: # Inventory
			update_inventory_tab()
			if slot_grid.get_child_count() > 0:
				slot_grid.get_child(0).grab_focus()
		
		1: # Charms
			update_charms_tab()
			if equipped_charms_grid.get_child_count() > 0:
				equipped_charms_grid.get_child(0).grab_focus()
		
		2: # Settings
			if quit_button:
				quit_button.grab_focus()

		3: # Map
			pass
	
	update_header_animation()


func update_charms_tab() -> void:
	# Update the equipped slots
	for i in range(equipped_slots.size()):
		var slot: AnimatedSlot = equipped_slots[i]
		
		if i < GameState.equipped_charms.size():
			slot.item_data = GameState.equipped_charms[i]
		else:
			slot.item_data = null
	
	var unequipped_charms: Array[CharmItem] = []
	for charm in GameState.collected_charms:
		if not charm in GameState.equipped_charms:
			unequipped_charms.append(charm)
	
	# Update the unequipped slots
	for i in range(available_slots.size()):
		var slot: AnimatedSlot = available_slots[i]
		
		if i < unequipped_charms.size():
			slot.item_data = unequipped_charms[i]
		else:
			slot.item_data = null


func update_tab_name() -> void:
	match current_tab:
		0: tab_name_label.text = "Inventory"
		1: tab_name_label.text = "Charms"
		2: tab_name_label.text = "Settings"
		3: tab_name_label.text = "Map"


func update_item_info(item: ItemData) -> void:
	if item != null:
		item_name.text = item.item_name
		item_description.text = item.description
	else:
		item_name.text = "Empty"
		item_description.text = "null"

func use_active_item(item: ActiveItem) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	item.use(player)
	
	if slot_tween and slot_tween.is_running():
		slot_tween.kill()
	
	slot_tween = create_tween().set_parallel(false).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slot_tween.tween_property(focused_slot.icon_sprite, "scale", Vector2(0.6, 0.6), 0.1)
	slot_tween.tween_property(focused_slot.icon_sprite, "scale", Vector2.ONE, 0.2)
	
	if item.is_consumable:
		for slot in GameState.collected_items:
			if slot["item"] == item:
				slot["quantity"] -= 1
				if slot["quantity"] <= 0:
					GameState.collected_items.erase(slot)
				break
		
		update_inventory_tab()
		
		if focused_slot != null:
			_on_inventory_slot_focused(focused_slot)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_load_save_button_pressed() -> void:
	GameState.load_save_data()
	
	get_tree().paused = false
	
	get_tree().reload_current_scene()


func _on_slot_focused(slot: AnimatedSlot) -> void:
	focused_slot = slot
	if slot.item_data != null:
		charm_name.text = slot.item_data.item_name
		charm_description.text = slot.item_data.description
	else:
		charm_name.text = "Empty"
		charm_description.text = ""


func _on_equipped_slot_pressed(slot: AnimatedSlot) -> void:
	if slot.item_data != null:
		GameState.unequip_charm(slot.item_data)
		update_charms_tab()


func _on_available_slot_pressed(slot: AnimatedSlot) -> void:
	if slot.item_data != null:
		GameState.equip_charm(slot.item_data)
		update_charms_tab()


func _on_inventory_slot_focused(slot: AnimatedSlot) -> void:
	focused_slot = slot
	if slot.item_data != null:
		item_name.text = slot.item_data.item_name
		item_description.text = slot.item_data.description
	else:
		item_name.text = "Empty"
		item_description.text = ""
