extends AnimatableBody2D

@export var lever: Lever

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var activated: bool = false

func _ready() -> void:
	if lever:
		lever.lever_activated.connect(_on_lever_activated)
		lever.lever_deactivated.connect(_on_lever_deactivated)
		
		# Sync initial state instantly
		if lever.is_activated:
			animation_player.play("open")
			animation_player.advance(100.0)
			activated = true
		else:
			animation_player.play("RESET")
			activated = false


func _on_lever_activated() -> void:
	if not activated:
		animation_player.play("open")
		activated = true


func _on_lever_deactivated() -> void:
	if activated:
		animation_player.play("close")
		activated = false
