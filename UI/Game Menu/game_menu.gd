extends CanvasLayer

@onready var tab_content: Control = %TabContent
@onready var tabs = [%InventoryTab, %SettingsTab, %MapTab]
@onready var tab_name_label: Label = $TabNameLabel
@onready var quit_button: Button = %QuitButton
@onready var slot_grid: GridContainer = %SlotGrid
@onready var item_name: Label = %ItemName
@onready var item_description: RichTextLabel = %ItemDescription
@onready var save_button: AnimatedButton = %SaveButton

var current_tab: int = 0
var is_menu_open: bool = false


func _ready() -> void:
	hide()
	update_tabs()
	
	GameEvents.inventory_item_focused.connect(update_item_info)


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


func toggle_menu() -> void:
	is_menu_open = !is_menu_open
	visible = is_menu_open
	
	get_tree().paused = is_menu_open
	
	if is_menu_open:
		update_tabs()


func update_tabs() -> void:
	for i in range(tabs.size()):
		tabs[i].visible = (i == current_tab)
		update_tab_name()
		
		# TODO : change opacity of other tabs
	
	if is_menu_open:
		if current_tab == 0:
			# Inventory
			if slot_grid.get_child_count() > 0:
				slot_grid.get_child(0).grab_focus()
		
		elif current_tab == 1:
			# Settings
			if quit_button:
				quit_button.grab_focus()
		
		
		elif current_tab == 2:
			# Map
			pass


func update_tab_name() -> void:
	match current_tab:
		0: tab_name_label.text = "Inventory"
		1: tab_name_label.text = "Settings"
		2: tab_name_label.text = "Map"


func update_item_info(item: ItemData) -> void:
	if item != null:
		item_name.text = item.item_name
		item_description.text = item.description
	else:
		item_name.text = ""
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
