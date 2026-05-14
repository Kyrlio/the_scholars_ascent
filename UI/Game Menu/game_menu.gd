extends CanvasLayer

@onready var tabs = [%InventoryTab, %CharmsTab, %SettingsTab, %MapTab]

@onready var tab_content: Control = %TabContent
@onready var tab_name_label: Label = $TabNameLabel
@onready var quit_button: Button = %QuitButton
@onready var slot_grid: GridContainer = %SlotGrid
@onready var item_name: Label = %ItemName
@onready var item_description: RichTextLabel = %ItemDescription
@onready var save_button: AnimatedButton = %SaveButton

@onready var equipped_charms_grid: GridContainer = %EquippedCharmsGrid
@onready var charm_slot_grid: GridContainer = %CharmSlotGrid
@onready var charm_name: Label = %CharmName
@onready var charm_description: RichTextLabel = %CharmDescription

@onready var equipped_slots: Array = equipped_charms_grid.get_children()
@onready var available_slots: Array = charm_slot_grid.get_children()
@onready var inventory_slots: Array = slot_grid.get_children()


var current_tab: int = 0
var is_menu_open: bool = false


func _ready() -> void:
	hide()
	update_tabs()
	
	GameEvents.inventory_item_focused.connect(update_item_info)
	
	for slot in equipped_slots:
		slot.focus_entered.connect(_on_slot_focused.bind(slot))
		slot.pressed.connect(_on_equipped_slot_pressed.bind(slot))
	
	for slot in available_slots:
		slot.focus_entered.connect(_on_slot_focused.bind(slot))
		slot.pressed.connect(_on_available_slot_pressed.bind(slot))
	
	for slot in inventory_slots:
		slot.focus_entered.connect(_on_inventory_slot_focused.bind(slot))


func _process(delta: float) -> void:	
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
	
	elif Input.is_action_just_pressed("tab_left"):
		current_tab = (current_tab - 1 + tabs.size()) % tabs.size()
		update_tabs()
		get_viewport().set_input_as_handled()
	
	elif Input.is_action_just_pressed("roll"):
		toggle_menu()
		get_viewport().set_input_as_handled()


func toggle_menu() -> void:
	if get_tree().paused and not is_menu_open:
		return
	
	is_menu_open = !is_menu_open
	visible = is_menu_open
	
	Input.action_release("roll")
	await get_tree().physics_frame
	await get_tree().physics_frame
	
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


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_save_button_pressed() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	
	if player != null:
		SaveManager.save_game(player.global_position, player.get_current_health(), GameState.total_gold)


func _on_load_save_button_pressed() -> void:
	GameState.load_save_data()
	
	get_tree().paused = false
	
	get_tree().reload_current_scene()


func _on_slot_focused(slot: AnimatedSlot) -> void:
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
	if slot.item_data != null:
		item_name.text = slot.item_data.item_name
		item_description.text = slot.item_data.description
	else:
		item_name.text = "Empty"
		item_description.text = ""
