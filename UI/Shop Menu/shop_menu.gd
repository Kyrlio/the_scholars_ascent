extends CanvasLayer
class_name ShopMenu

const GOLD_ICON = preload("uid://caqd2vijw2q1g")

@onready var shop_slot_grid: GridContainer = %ShopSlotGrid
@onready var shop_slots = %ShopSlotGrid.get_children()
@onready var item_name: Label = %ItemName
@onready var item_description: RichTextLabel = %ItemDescription
@onready var price_label: Label = %PriceLabel
@onready var price_icon: TextureRect = %PriceIcon

var current_inventory: Array[ShopItem] = []
var selected_item: ShopItem = null


func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for i in range(shop_slots.size()):
		shop_slots[i].focus_entered.connect(_on_slot_focused.bind(i))
		
		if shop_slots[i] is BaseButton:
			shop_slots[i].pressed.connect(_on_slot_pressed.bind(i))


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("roll"):
		close_shop()
		get_viewport().set_input_as_handled()


func open_shop(inventory: Array[ShopItem]) -> void:
	current_inventory = inventory
	populate_shop()
	show()
	get_tree().paused = true
	
	if shop_slots.size() > 0 and current_inventory.size() > 0:
		shop_slots.front().grab_focus()

func close_shop() -> void:
	if not visible:
		return
	hide()
	Input.action_release("roll")
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = false


func populate_shop() -> void:
	for i in range(shop_slots.size()):
		var slot: AnimatedSlot = shop_slots[i]
		
		if i < current_inventory.size():
			var shop_item = current_inventory[i]
			
			if shop_item.resource_path != "" and GameState.shop_stocks.has(shop_item.resource_path):
				shop_item.stock = GameState.shop_stocks[shop_item.resource_path]
			
			slot.quantity = shop_item.stock
			slot.item_data = shop_item.item 
			slot.show()
			
			if shop_item.stock == 0:
				slot.modulate = Color(0.5, 0.5, 0.5, 1.0)
				slot.disabled = true
			elif shop_item.stock > 0:
				slot.modulate = Color(1, 1, 1, 1)
				slot.disabled = false
			else:
				slot.modulate = Color(1, 1, 1, 1)
				slot.disabled = false
		else:
			slot.item_data = null
			slot.hide() 


func _on_slot_focused(index: int) -> void:
	if index < current_inventory.size():
		selected_item = current_inventory[index]
		item_name.text = selected_item.item.item_name
		item_description.text = selected_item.item.description
		
		if selected_item.currency_item == null:
			price_label.text = "Price : " + str(selected_item.price) + " Gold"
			price_icon.texture = GOLD_ICON
		else:
			price_label.text = "Price : " + str(selected_item.price) + " " + selected_item.currency_item.item_name
			price_icon.texture = selected_item.currency_item.icon
	else:
		selected_item = null


func _on_slot_pressed(index: int) -> void:
	if index < current_inventory.size():
		selected_item = current_inventory[index]
		buy_selected_item()


func buy_selected_item() -> void:
	if selected_item == null: return
	
	if selected_item.stock == 0:
		print("No stock for ", selected_item.item.item_name)
		return
	
	if selected_item.currency_item == null:
		if GameState.total_gold >= selected_item.price:
			GameState.total_gold -= selected_item.price
			GameEvents.emit_item_collected(selected_item.item)
			if selected_item.stock > 0:
				selected_item.stock -= 1
			
			if selected_item.resource_path != "":
				print(selected_item.resource_path)
				GameState.shop_stocks[selected_item.resource_path] = selected_item.stock
			
			print(selected_item.item.item_name + " buyed with gold")
		else:
			print("Not enough money")
	else:
		var has_enough = false
		for slot in GameState.collected_items:
			if slot["item"] == selected_item.currency_item and slot["quantity"] >= selected_item.price:
				slot["quantity"] -= selected_item.price
				has_enough = true
				if slot["quantity"] <= 0:
					GameState.collected_items.erase(slot)
				break
		
		if has_enough:
			GameEvents.emit_item_collected(selected_item.item)
			if selected_item.stock > 0:
				selected_item.stock -= 1
			
			if selected_item.resource_path != "":
				GameState.shop_stocks[selected_item.resource_path] = selected_item.stock
			
			print(selected_item.item.item_name + " buyed with ", selected_item.currency_item.item_name)
		else:
			print("Not enough ", selected_item.currency_item.item_name, " to buy")
	
	GameEvents.emit_gold_collected(0)
	populate_shop()
