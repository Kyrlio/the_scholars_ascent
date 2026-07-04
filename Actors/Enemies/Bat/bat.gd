extends CharacterBody2D
class_name Bat

@export var enemy_id: String = ""
@export var chase_speed: float = 25.0
@export var dash_speed: float = 225.0
@export var dash_length: float = 0.35 ## In seconds
@export var hover_altitude: float = 35.0 ## Distance above the player

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var attack_timer: Timer = $AttackTimer
@onready var vision_area: Area2D = $VisionArea2D
@onready var attack_area: Area2D = $AttackArea2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var states: Node = $States
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent

@onready var state: EnemyState : set = set_state

var direction: float = 1.0
var is_dead: bool = false
var last_player_position: Vector2

func _ready() -> void:
	enemy_id = GameState.get_unique_enemy_id(self)
	
	if enemy_id != "" and enemy_id in GameState.defeated_enemies:
		queue_free()
		return
	
	hitbox_component.set_deferred("monitorable", true)
	hurtbox_component.set_deferred("monitoring", true)
	
	for child in states.get_children():
		child.context = self
	
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)
	
	animation_player.play("spawn")
	
	await animation_player.animation_finished
	
	set_state($States/IdleState)

func set_state(new_state: EnemyState) -> void:
	if state:
		state.exit()
		new_state.previous_state = state
	state = new_state
	state.enter()


func _physics_process(delta: float) -> void:
	if is_dead: return
	
	if GameState.is_gameplay_frozen():
		velocity = velocity.move_toward(Vector2.ZERO, 800 * delta)
		move_and_slide()
		return
	
	if state:
		state.physics_update(delta)
	
	move_and_slide()


func update_facing(target_pos: Vector2) -> void:
	var diff_x = target_pos.x - global_position.x
	if abs(diff_x) > 5.0:
		direction = sign(diff_x)
		visuals.scale.x = direction


func _on_damaged() -> void:
	set_state($States/HitState)


func _on_died() -> void:
	set_state($States/DeadState)
	return
