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
		if owner != null and owner.scene_file_path != "":
			lever_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			lever_id = str(get_path())
	
	if GameState.activated_levers.has(lever_id):
		is_activated = GameState.activated_levers[lever_id]
	else:
		GameState.activated_levers[lever_id] = is_activated
	
	if is_activated:
		animation_player.play("activate")
		lever_activated.emit.call_deferred()
	else:
		animation_player.play("deactivate")
		lever_deactivated.emit.call_deferred()


func activate_lever() -> void:
	is_activated = true
	animation_player.play("activate")
		
	if lever_id != "":
		GameState.activated_levers[lever_id] = true
	
	lever_activated.emit.call_deferred()


func deactivate_lever() -> void:
	is_activated = false
	animation_player.play("deactivate")
	
	if lever_id != "":
		GameState.activated_levers[lever_id] = false
	
	lever_deactivated.emit.call_deferred()


func _on_hit(hitbox: HitboxComponent) -> void:
	pogo_particles.restart()
	if not is_activated:
		activate_lever()
	else:
		deactivate_lever()
