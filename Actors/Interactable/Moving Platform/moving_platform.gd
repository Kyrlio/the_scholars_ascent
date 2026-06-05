extends Node2D

## (320, 0) = droite, (-320, 0) = gauche, (0, -320) = haut, (0, 320) = bas
@export var offset: Vector2 = Vector2(320, 0)
@export var duration: float = 10.0

@export_group("Rail Textures")
@export var rail_start: Texture2D
@export var rail_middle: Texture2D
@export var rail_end: Texture2D


@onready var platform_body: AnimatableBody2D = $PlatformBody

func _ready() -> void:
	_generate_rails()
	
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.set_loops().set_parallel(false)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(platform_body, "position", offset, duration / 2.0).from_current()
	tween.tween_property(platform_body, "position", Vector2.ZERO, duration / 2.0)


func _generate_rails() -> void:
	var tile_size: int = 16
	var distance: float = offset.length()
	var direction: Vector2 = offset.normalized()
	
	var num_tiles: int = int(distance / tile_size)
	
	var rail_container = Node2D.new()
	rail_container.position.y += 2
	add_child(rail_container)
	move_child(rail_container, 0)
	
	for i in range(num_tiles + 1):
		var sprite = Sprite2D.new()
		
		if i == 0:
			sprite.texture = rail_start
		elif i == num_tiles:
			sprite.texture = rail_end
		else:
			sprite.texture = rail_middle
		
		sprite.rotation = direction.angle()
		
		sprite.position = direction * (i * tile_size)
		
		rail_container.add_child(sprite)
	
	
	
