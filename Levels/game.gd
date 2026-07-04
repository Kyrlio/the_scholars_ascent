class_name Game
extends Node2D

signal loading_finished

@export var freeze_slow: float = 0.06
@export var freeze_time: float = 0.2

@onready var level_container: Node2D = $LevelContainer

var player: Player
var is_pause_menu_open: bool = false
var loading_finished_emitted: bool = false

func _ready() -> void:
	player = level_container.find_child("Player", true, false)
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if GameState.saved_room != "" and GameState.saved_room != "zone1_room1":
		var room_name = GameState.saved_room
		if SceneManager.scenes.has(room_name):
			var room_container = level_container.get_node("CurrentRoom")
			if room_container:
				if room_container.get_child_count() > 0:
					var old_room = room_container.get_child(0)
					room_container.remove_child(old_room)
					old_room.queue_free()
				
				var packed_scene = load(SceneManager.scenes[room_name])
				if packed_scene:
					var new_room = packed_scene.instantiate()
					new_room.name = room_name
					room_container.add_child(new_room)
	
	var camera = get_tree().get_first_node_in_group("camera")
	var room_tilemap = find_child("Ground", true, false)
	camera.update_limits(room_tilemap)
	
	# Game Events signals
	GameEvents.engine_freeze_requested.connect(freeze_engine)
	
	MetSys.reset_state()
	MetSys.set_save_data()
	
	_emit_loading_finished.call_deferred()


func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		MetSys.set_player_position(player.position)


func _emit_loading_finished() -> void:
	if loading_finished_emitted:
		return
	
	loading_finished_emitted = true
	loading_finished.emit()


func request_loading_finished() -> void:
	if loading_finished_emitted:
		return
	 
	_emit_loading_finished.call_deferred()


func has_loading_finished() -> bool:
	return loading_finished_emitted


func freeze_engine() -> void:
	if Engine.time_scale != 1.0:
		return
	
	Engine.time_scale = freeze_slow
	await get_tree().create_timer(freeze_time * freeze_slow).timeout
	Engine.time_scale = 1.0
