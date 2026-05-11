extends Node

var total_gold: int = 0

var saved_player_pos: Vector2 = Vector2.ZERO
var saved_player_health: int = -1

func _ready() -> void:
	GameEvents.gold_collected.connect(add_gold)
	
	load_save_data()


func add_gold(amount: int) -> void:
	total_gold += amount


func load_save_data():
	var data = SaveManager.load_game()
	
	if not data.is_empty():
		total_gold = data.get("gold", 0)
		saved_player_health = data.get("health", 2)
		
		var pos_x = data.get("player_pos_x", 0.0)
		var pos_y = data.get("player_pos_y", 0.0)
		saved_player_pos = Vector2(pos_x, pos_y)
