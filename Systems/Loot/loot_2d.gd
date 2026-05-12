extends Marker2D
class_name Loot2D


@export var loot_scene: PackedScene
@export_range(0.0, 1.0) var drop_rate: float = 1.0

func drop() -> void:
	var luck := randf()
	
	if luck <= drop_rate and loot_scene != null:
		var loot = loot_scene.instantiate()
		loot.global_position = global_position
		
		get_tree().current_scene.add_child.call_deferred(loot)
