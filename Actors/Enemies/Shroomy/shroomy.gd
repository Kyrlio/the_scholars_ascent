extends CharacterBody2D
class_name Shroomy

@export var enemy_id: String = ""
@export var speed: float = 30.0
@export var chase_speed: float = 60.0
@export var gravity: float = 500.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = %HitboxComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent

@onready var visuals: Node2D = $Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var states: Node = $States

@onready var vision_area: Area2D = %VisionArea2D
@onready var attack_area: Area2D = %AttackArea2D

@onready var ledge_detection_ray: RayCast2D = %LedgeDetectionRay
@onready var wall_detection_ray: RayCast2D = %WallDetectionRay

@onready var state: EnemyState : set = set_state

var direction: float = 1.0
var is_dead: bool = false
var can_move: bool = true
var player: Player = null

func _ready() -> void:
	enemy_id = GameState.get_unique_enemy_id(self)
	
	if enemy_id != "" and enemy_id in GameState.defeated_enemies:
		queue_free()
		return
	
	for child_state in states.get_children():
		child_state.context = self
	
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)
	
	set_state($States/PatrolState)


func _physics_process(delta: float) -> void:
	if GameState.is_gameplay_frozen():
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.x = move_toward(velocity.x, 0, 800 * delta)
		move_and_slide()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if state:
		state.physics_update(delta)
	
	move_and_slide()


func set_state(new_state: EnemyState) -> void:
	if state:
		state.exit()
		new_state.previous_state = state
	
	state = new_state
	state.enter()


func update_direction() -> void:
	if not wall_detection_ray.is_colliding() and ledge_detection_ray.is_colliding():
		return
	
	direction *= -1.0
	visuals.scale = Vector2(direction, 1)

func update_facing() -> void:
	if is_instance_valid(player):
		var diff_x = player.global_position.x - global_position.x
		if abs(diff_x) > 5.0:
			direction = sign(diff_x)
	visuals.scale.x = direction


func _on_damaged() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	update_facing()
	set_state($States/HitState)


func _on_died() -> void:
	set_state($States/DeadState)
