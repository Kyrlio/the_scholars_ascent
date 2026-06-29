extends Area2D
class_name Arrow

@export var speed: float = 175.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const HIT_PARTICLES = preload("uid://bb6uks6vkiknu")

var direction: Vector2 = Vector2.ZERO

func start(_pos: Vector2, _dir: Vector2) -> void:
	global_position = _pos
	direction = _dir
	rotation = direction.angle()
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func spawn_particles() -> void:
	var particles: GPUParticles2D = HIT_PARTICLES.instantiate()
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)


func _on_body_entered(body: Node2D) -> void:
	spawn_particles()
	queue_free.call_deferred()


func _on_hitbox_component_hit_hurtbox(hurtbox_component: HurtboxComponent) -> void:
	spawn_particles()
	queue_free.call_deferred()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free.call_deferred()
