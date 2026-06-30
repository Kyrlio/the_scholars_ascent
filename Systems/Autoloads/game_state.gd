extends Node

const MAX_EQUIPPED_CHARMS: int = 3

var collected_items: Array[Dictionary] = []
var collected_charms: Array[CharmItem] = []
var equipped_charms: Array[CharmItem] = []
var collected_coins: Array = []
var shop_stocks: Dictionary = {}
var activated_levers: Dictionary = {}
var defeated_enemies: Array = []
var played_cutscenes: Array = []

func has_cutscene_been_played(cutscene_id: String) -> bool:
	return cutscene_id in played_cutscenes

func mark_cutscene_as_played(cutscene_id: String) -> void:
	if not cutscene_id in played_cutscenes:
		played_cutscenes.append(cutscene_id)

func reset_cutscene(cutscene_id: String) -> void:
	if cutscene_id in played_cutscenes:
		played_cutscenes.erase(cutscene_id)

var opened_chests: Array = []
var opened_star_doors: Array = []

var total_gold: int = 0
var unlocked_max_health: int = 2
var collected_heart_containers: Array = []

var saved_player_pos: Vector2 = Vector2.ZERO
var saved_player_health: int = -1
var saved_room: String = ""

var base_player_stats: Stats = preload("res://Systems/Resources/base_player_stats.tres")

var unlocked_abitilities: Array[String] = []

var is_dialogue_active: bool = false
var is_shop_active: bool = false

func is_gameplay_frozen() -> bool:
	return is_dialogue_active or is_shop_active

func _ready() -> void:
	GameEvents.gold_collected.connect(add_gold)
	GameEvents.item_collected.connect(_on_item_collected)
	
	DialogueManager.dialogue_started.connect(func(_resource): is_dialogue_active = true)
	DialogueManager.dialogue_ended.connect(func(_resource):
		await get_tree().physics_frame
		await get_tree().physics_frame
		is_dialogue_active = false
	)
	
	load_save_data()


func add_gold(amount: int) -> void:
	total_gold += amount


func has_ability(ability_name: String) -> bool:
	return ability_name in unlocked_abitilities


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
	collected_coins = data.get("collected_coins", [])
	saved_player_health = data.get("health", 2)
	unlocked_max_health = data.get("unlocked_max_health", 2)
	collected_heart_containers = data.get("collected_heart_containers", [])
	var raw_levers = data.get("activated_levers", {})
	if typeof(raw_levers) == TYPE_ARRAY:
		activated_levers = {}
		for id in raw_levers:
			activated_levers[id] = true
	else:
		activated_levers = raw_levers
	shop_stocks = data.get("shop_stocks", {})
	
	var pos_x = data.get("player_pos_x", 0.0)
	var pos_y = data.get("player_pos_y", 0.0)
	saved_player_pos = Vector2(pos_x, pos_y)
	saved_room = data.get("saved_room", "")
	
	# Classic inventory
	collected_items.clear()
	for data_slot in data.get("collected_items", []):
		if typeof(data_slot) == TYPE_DICTIONARY and ResourceLoader.exists(data_slot["path"]):
			var item_res = load(data_slot["path"])
			collected_items.append({
				"item": item_res,
				"quantity": data_slot["quantity"]
			})
	
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
	
	# Chests opened
	opened_chests = data.get("opened_chests", [])
	
	# Star doors opened
	opened_star_doors = data.get("opened_star_doors", [])
	
	# Shop stocks
	shop_stocks = data.get("shop_stocks", {})
	for path in shop_stocks:
		if ResourceLoader.exists(path):
			var shop_item = load(path)
			shop_item.stock = shop_stocks[path]
	
	# Abilities
	var loaded_abilities = data.get("unlocked_abilities", [])
	unlocked_abitilities.assign(loaded_abilities)
	
	# Defeated enemies
	defeated_enemies = data.get("defeated_enemies", [])
	
	# Played cutscenes
	played_cutscenes = data.get("played_cutscenes", [])
	
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


func reset_state() -> void:
	for path in shop_stocks:
		if ResourceLoader.exists(path):
			ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
	
	collected_items.clear()
	collected_charms.clear()
	equipped_charms.clear()
	collected_coins.clear()
	shop_stocks.clear()
	activated_levers.clear()
	defeated_enemies.clear()
	played_cutscenes.clear()
	opened_chests.clear()
	opened_star_doors.clear()
	
	total_gold = 0
	unlocked_max_health = 2
	collected_heart_containers.clear()
	
	saved_player_pos = Vector2.ZERO
	saved_player_health = -1
	saved_room = ""
	
	unlocked_abitilities.clear()
	
	is_dialogue_active = false
	is_shop_active = false
	
	rebuild_player_stats()
			
		
