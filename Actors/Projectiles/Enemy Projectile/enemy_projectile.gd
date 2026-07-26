extends Area2D
class_name EnemyProjectile

@export var speed: float = 200.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const HIT_PARTICLES = preload("uid://bb6uks6vkiknu")

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if hitbox_component:
		hitbox_component.hit_hurtbox.connect(_on_hitbox_hit)
	
	body_entered.connect(_on_body_entered)


func start(pos: Vector2, dir: Vector2) -> void:
	global_position = pos
	direction = dir
	rotation = direction.angle()
	reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_hitbox_hit(_hurtbox: HurtboxComponent) -> void:
	_deactivate()


func _on_body_entered(_body: Node2D) -> void:
	_deactivate()


func _deactivate() -> void:
	spawn_particles()
	queue_free.call_deferred()


func spawn_particles() -> void:
	var particles: GPUParticles2D = HIT_PARTICLES.instantiate()
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	particles.finished.connect(particles.queue_free)
