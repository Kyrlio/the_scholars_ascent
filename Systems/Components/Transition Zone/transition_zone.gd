extends Area2D
class_name TransitionZone

@export var target_room: String = "" #Ex: "Room_1B"
@export var target_zone_name: String = "" #Ex: "SpawnLeft"

@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		TeleportData.target_transition_name = target_zone_name
		SceneManager.change_room.call_deferred(target_room)


func get_spawn_point() -> Marker2D:
	return spawn_point
