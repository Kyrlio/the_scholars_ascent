extends Node2D
class_name Lever

signal lever_activated
signal lever_deactivated

@export var lever_id: String = ""
@export var is_activated: bool = false

@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pogo_particles: GPUParticles2D = $PogoParticles



func _ready() -> void:
	if hurtbox_component:
		hurtbox_component.hit_by_hitbox.connect(_on_hit)
	
	if lever_id == "":
		lever_id = str(get_path())
	
	if lever_id in GameState.activated_levers:
		is_activated = true
		animation_player.play("activate")
		lever_activated.emit.call_deferred()
	
	if is_activated:
		activate_lever()


func activate_lever() -> void:
	is_activated = true
	animation_player.play("activate")
		
	if lever_id != "" and not lever_id in GameState.activated_levers:
		GameState.activated_levers.append(lever_id)
	
	lever_activated.emit.call_deferred()


func deactivate_lever() -> void:
	is_activated = false
	animation_player.play("deactivate")
	
	if lever_id != "" and lever_id in GameState.activated_levers:
		GameState.activated_levers.erase(lever_id) 
	
	lever_deactivated.emit.call_deferred()


func _on_hit(hitbox: HitboxComponent) -> void:
	pogo_particles.restart()
	if not is_activated:
		activate_lever()
	else:
		deactivate_lever()
