extends AnimatableBody2D

@export var lever: Lever

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var activated: bool = false

func _ready() -> void:
	if lever:
		lever.lever_activated.connect(activate_trapdoor)
		lever.lever_deactivated.connect(activate_trapdoor)


func activate_trapdoor() -> void:
	if not activated:
		animation_player.play("open")
		activated = true
	else:
		animation_player.play("close")
		activated = false
