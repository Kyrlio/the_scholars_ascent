class_name HurtboxComponent
extends Area2D

signal hit_by_hitbox(hitbox_component: HitboxComponent)

@export var health_component: HealthComponent
@export var hit_particles_scene: PackedScene

var peer_id_filter: int = -1
var disable_collisions: bool
var is_invincible: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _handle_hit(hitbox_component: HitboxComponent):
	if not is_instance_valid(hitbox_component) or hitbox_component.is_hit_handled or disable_collisions:
		# Hit only one enemy
		return
	
	if is_invincible:
		hitbox_component.register_hurtbox_hit(self)
		hit_by_hitbox.emit(hitbox_component)
		return
	
	hitbox_component.register_hurtbox_hit(self)
	GameEvents.emit_engine_freeze()
	if health_component:
		health_component.damage(hitbox_component.damage)
	
	# Instantiate hit particles if configured
	if hit_particles_scene:
		_play_hit_particles(hitbox_component)
	
	hit_by_hitbox.emit(hitbox_component)


func _play_hit_particles(hitbox_component: HitboxComponent) -> void:
	var particles: GPUParticles2D = hit_particles_scene.instantiate()
		
	# Determine hit direction (away from hitbox)
	var diff_x = global_position.x - hitbox_component.global_position.x
	var hit_dir_x = sign(diff_x) if diff_x != 0.0 else 1.0
	
	# Apply scale and position
	particles.scale.x = hit_dir_x
	particles.global_position = global_position
	
	# Add to the current scene so they aren't affected by parent's transform/deletion
	var scene_root = get_tree().current_scene
	if scene_root:
		scene_root.add_child(particles)
		particles.emitting = true
		particles.finished.connect(particles.queue_free)


func spawn_particles() -> void:
	var particles: GPUParticles2D = hit_particles_scene.instantiate()
	
	var scene_root = get_tree().current_scene
	if scene_root:
		scene_root.add_child(particles)
		particles.emitting = true
		particles.finished.connect(particles.queue_free)


func _on_area_entered(other_area: Area2D) -> void:
	if other_area is not HitboxComponent:
		return
	
	var _hitbox_component: HitboxComponent = other_area
	
	_handle_hit.call_deferred(other_area)


func toggle_invincibility(toggled: bool) -> void:
	is_invincible = toggled
