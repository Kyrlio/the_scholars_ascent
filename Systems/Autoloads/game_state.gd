extends Node

const MAX_EQUIPPED_CHARMS: int = 3

#var collected_items: Array[ItemData] = []
var collected_items: Array[Dictionary] = []
var collected_charms: Array[CharmItem] = []
var equipped_charms: Array[CharmItem] = []

var total_gold: int = 0

var saved_player_pos: Vector2 = Vector2.ZERO
var saved_player_health: int = -1

var base_player_stats: Stats = preload("res://Systems/Resources/base_player_stats.tres")

func _ready() -> void:
	GameEvents.gold_collected.connect(add_gold)
	GameEvents.item_collected.connect(_on_item_collected)
	
	load_save_data()


func add_gold(amount: int) -> void:
	total_gold += amount


func equip_charm(charm: CharmItem) -> void:
	if equipped_charms.size() >= MAX_EQUIPPED_CHARMS:
		print("Plus de place pour équiper de nouveaux charmes !")
		return
	
	if not charm in equipped_charms:
		equipped_charms.append(charm)
		rebuild_player_stats()
		print(charm.item_name + " équipé avec succès !")


func unequip_charm(charm: CharmItem) -> void:
	if charm in equipped_charms:
		equipped_charms.erase(charm)
		rebuild_player_stats()
		print(charm.item_name + " retiré !")


func rebuild_player_stats() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var current_layer: Stats = base_player_stats
	
	for charm in equipped_charms:
		if charm.stat_modifier:
			charm.stat_modifier.decorated_stats = current_layer
			current_layer = charm.stat_modifier
	
	player.stats = current_layer


func load_save_data():
	var data = SaveManager.load_game()
	if data.is_empty():
		return
	
	total_gold = data.get("gold", 0)
	saved_player_health = data.get("health", 2)
	
	var pos_x = data.get("player_pos_x", 0.0)
	var pos_y = data.get("player_pos_y", 0.0)
	saved_player_pos = Vector2(pos_x, pos_y)
	
	# Classic inventory
	collected_items.clear()
	for data_slot in data.get("collected_items", []):
		if typeof(data_slot) == TYPE_DICTIONARY and ResourceLoader.exists(data_slot["path"]):
			var item_res = load(data_slot["path"])
			collected_items.append({
				"item": item_res,
				"quantity": data_slot["quantity"]
			})
	
	#for path in data.get("collected_items", []):
		#if ResourceLoader.exists(path):
			#collected_items.append(load(path))
	
	# Charm inventory
	collected_charms.clear()
	for path in data.get("collected_charms", []):
		if ResourceLoader.exists(path):
			collected_charms.append(load(path))
	
	# Charms equipped
	equipped_charms.clear()
	for path in data.get("equipped_charms", []):
		if ResourceLoader.exists(path):
			equipped_charms.append(load(path))
	
	rebuild_player_stats()

func _on_item_collected(new_item: ItemData) -> void:
	if new_item is CharmItem:
		collected_charms.append(new_item)
		print("Charme ajouté a l'onglet des charmes")
	else:
		var found: bool = false
		
		for slot in collected_items:
			if slot["item"] == new_item:
				slot["quantity"] += 1
				found = true
				print(new_item.item_name + " stacké ! (Total " + str(slot["quantity"]) + " )")
				break
		
		if not found:
			collected_items.append({"item": new_item, "quantity": 1})
			print("Objet ajouté a l'inventaire")
			
		
