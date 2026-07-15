extends RigidBody2D
class_name Bomb

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_shape: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	hitbox_shape.disabled = true
	animation_player.play("tick")


func _physics_process(delta: float) -> void:
	if is_instance_valid(sprite):
		sprite.global_rotation = 0.0


func explode() -> void:
	linear_velocity = Vector2.ZERO
	freeze = true
	# TODO: Audio
	animation_player.play("explosion")
	await animation_player.animation_finished
	queue_free.call_deferred()
