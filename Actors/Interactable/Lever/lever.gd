extends Node2D
class_name Lever

signal lever_activated
signal lever_deactivated

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pogo_particles: GPUParticles2D = $PogoParticles

var is_activated: bool = false


func _ready() -> void:
	if hurtbox_component:
		hurtbox_component.hit_by_hitbox.connect(_on_hit)


func _on_hit(hitbox: HitboxComponent) -> void:
	pogo_particles.restart()
	if not is_activated:
		is_activated = true
		animation_player.play("activate")
		lever_activated.emit()
	else:
		is_activated = false
		animation_player.play("deactivate")
		lever_deactivated.emit()
