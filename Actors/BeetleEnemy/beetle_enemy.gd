extends CharacterBody2D
class_name BeetleEnemy

@onready var ledge_detection_ray: RayCast2D = %LedgeDetectionRay
@onready var wall_detection_ray: RayCast2D = %WallDetectionRay
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var loots_container: Node2D = %Loots


@export var enemy_id: String = ""
@export var speed: float = 10.0
@export var gravity: float = 500.0
@export var hit_stop_duration: float = 0.25


var direction: float = 1.0
var is_dead: bool = false
var can_move: bool = true


func _ready() -> void:
	if enemy_id == "":
		enemy_id = str(get_path())
	
	if enemy_id in GameState.defeated_enemies:
		queue_free()
		return
	
	if health_component:
		health_component.died.connect(_on_died)
		health_component.damaged.connect(_on_damaged)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not can_move:
		return
	
	_movement(delta)
	_update_direction()
	
	move_and_slide()


func _movement(delta) -> void:
	velocity.x = speed * direction
	velocity.y = gravity * delta


func _update_direction() -> void:
	if not wall_detection_ray.is_colliding() and ledge_detection_ray.is_colliding():
		return
	
	direction *= -1.0
	visuals.scale = Vector2(direction, 1)


func _on_damaged() -> void:
	can_move = false
	velocity.x = 0.0
	animation_player.play("hit")
	GameEvents.emit_camera_shake(0.2)
	
	await get_tree().create_timer(hit_stop_duration).timeout
	
	if not is_dead:
		can_move = true
		animation_player.play("default")


func _on_died() -> void:
	if enemy_id != "" and not enemy_id in GameState.defeated_enemies:
		GameState.defeated_enemies.append(enemy_id)
	
	if loots_container:
		for loot in loots_container.get_children():
			if loot.has_method("drop"):
				loot.drop()
	
	is_dead = true
	can_move = false
	velocity = Vector2.ZERO
	animation_player.play("death")
	
