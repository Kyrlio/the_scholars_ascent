extends Node2D

## (320, 0) = droite, (-320, 0) = gauche, (0, -320) = haut, (0, 320) = bas
@export var offset: Vector2 = Vector2(320, 0)
@export var duration: float = 10.0

@onready var platform_body: AnimatableBody2D = $PlatformBody

func _ready() -> void:
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	tween.set_loops().set_parallel(false)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(platform_body, "position", offset, duration / 2.0).from_current()
	tween.tween_property(platform_body, "position", Vector2.ZERO, duration / 2.0)
