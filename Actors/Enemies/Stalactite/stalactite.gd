extends CharacterBody2D
class_name Stalactite

enum State { IDLE, SHAKING, FALLING }
var current_state: State = State.IDLE

@export var fall_gravity: float = 700.0
@export var damage: int = 1
@export var particles_scene: PackedScene

@onready var player_detector: Area2D = %PlayerDetector
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox_component: HitboxComponent = $HitboxComponent


func _ready() -> void:
	hitbox_component.damage = damage
	
	player_detector.body_entered.connect(_on_player_detected)
	
	hitbox_component.area_entered.connect(_on_hitbox_hit)


func _physics_process(delta: float) -> void:
	if current_state == State.FALLING:
		velocity.y += fall_gravity * delta
		move_and_slide()
		
		if is_on_floor():
			_shatter()


func _on_player_detected(body: Node2D) -> void:
	if body is Player and current_state == State.IDLE:
		_start_shake()


func _start_shake() -> void:
	current_state = State.SHAKING
	
	var tw = create_tween()
	tw.tween_property(sprite, "position:x", 2.0, 0.05)
	tw.tween_property(sprite, "position:x", -2.0, 0.05)
	tw.tween_property(sprite, "position:x", 0.0, 0.05)
	tw.set_loops(3)
	
	await get_tree().create_timer(0.3).timeout
	current_state = State.FALLING


func _on_hitbox_hit(area: Area2D) -> void:
	if current_state == State.FALLING:
		_shatter()


func _shatter() -> void:
	var particles: GPUParticles2D = particles_scene.instantiate()
	particles.global_position = global_position
	
	var scene_root = get_tree().current_scene
	if scene_root:
		scene_root.add_child(particles)
		particles.emitting = true
		particles.finished.connect(particles.queue_free)
		
	# TODO Audio
	queue_free.call_deferred()
