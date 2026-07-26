extends StaticBody2D
class_name Cannon

@export var projectile_scene: PackedScene
@export var fire_cooldown: float = 2.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var muzzle: Marker2D = $Muzzle
@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	cooldown_timer.wait_time = fire_cooldown
	cooldown_timer.timeout.connect(_on_timer_timeout)
	
	cooldown_timer.start()


func _on_timer_timeout() -> void:
	animation_player.stop()
	animation_player.play("shoot")


func fire() -> void:
	if projectile_scene == null:
		return
	
	var projectile: EnemyProjectile = projectile_scene.instantiate()
	var aim_dir: Vector2 = global_transform.x.normalized()
	
	get_tree().current_scene.add_child(projectile)
	projectile.start(muzzle.global_position, aim_dir)
