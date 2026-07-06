extends CharacterBody2D
class_name Skeleton

@export var enemy_id: String = ""
@export var walk_speed: float = 20.0
@export var flee_speed: float = 75.0
@export var gravity: float = 500.0
@export var knockback_velocity: Vector2 = Vector2(80.0, -80.0)

@export var arrow_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var vision_area: Area2D = %VisionArea2D
@onready var flee_area: Area2D = %FleeArea2D
@onready var bow_marker: Marker2D = $Visuals/BowMarker
@onready var states: Node = $States

@onready var ledge_detection_ray: RayCast2D = %LedgeDetectionRay
@onready var wall_detection_ray: RayCast2D = %WallDetectionRay

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent
@onready var hitbox_component: HitboxComponent = %HitboxComponent

@onready var attack_timer: Timer = $AttackTimer

@onready var state: EnemyState: set = set_state

var direction: float = 1.0
var is_dead: bool = false
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
	
	if hurtbox_component:
		hurtbox_component.hit_by_hitbox.connect(_on_hit_by_hitbox)
	
	vision_area.body_entered.connect(_on_player_spotted)
	
	set_state($States/PatrolState)


func _physics_process(delta: float) -> void:
	if is_dead: return
	
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
	if direction != 0:
		visuals.scale.x = sign(direction)


func fire_arrow() -> void:
	var arrow: Arrow = arrow_scene.instantiate()
	arrow.position = bow_marker.global_position
	get_tree().get_root().add_child(arrow)
	
	var aim_dir: Vector2 = Vector2.RIGHT if visuals.scale.x > 0 else Vector2.LEFT
	arrow.start(bow_marker.global_position, aim_dir)


func _on_player_spotted(body: Node2D) -> void:
	if body is Player:
		player = body

func _on_hit_by_hitbox(hitbox: HitboxComponent) -> void:
	var push_dir = sign(global_position.x - hitbox.global_position.x)
	if push_dir == 0.0:
		push_dir = 1.0 if visuals.scale.x < 0 else -1.0
	
	velocity.x = push_dir * knockback_velocity.x
	velocity.y = knockback_velocity.y

func _on_damaged() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		var diff_x = player.global_position.x - global_position.x
		if abs(diff_x) > 5.0:
			direction = sign(diff_x)
	update_facing()
	set_state($States/HitState)


func _on_died() -> void:
	set_state($States/DeadState)
