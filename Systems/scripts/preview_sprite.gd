@tool
extends Sprite2D

@onready var spawner: Marker2D = get_parent()
var check_timer: float = 0.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		hide()


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	check_timer += delta
	if check_timer > 0.5:
		check_timer = 0.0
		if "enemy_definition" in spawner and spawner.enemy_definition != null:
			if texture != spawner.enemy_definition.preview_texture:
				texture = spawner.enemy_definition.preview_texture
		else:
			texture = null
