extends CharacterBody2D
class_name Bat

@export var enemy_id: String = ""
@export var chase_speed: float = 25.0
@export var dash_speed: float = 200.0
@export var dash_length: float = 0.3 ## In seconds
@export var hover_altitude: float = 25.0 ## Distance above the player

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

func _ready() -> void:
	if enemy_id == "":
		if owner != null and owner.scene_file_path != "":
			enemy_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
		else:
			enemy_id = str(get_path())
	
	if enemy_id != "" and enemy_id in GameState.defeated_enemies:
		queue_free()
		return
	
	hitbox_component.set_deferred("monitorable", true)
	hurtbox_component.set_deferred("monitoring", true)
	
	for child in states.get_children():
		child.context = self
	
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)
	
	set_state($States/IdleState)

func set_state(new_state: EnemyState) -> void:
	if state:
		state.exit()
		new_state.previous_state = state
	state = new_state
	state.enter()


func _physics_process(delta: float) -> void:
	if is_dead: return
	
	if state:
		state.physics_update(delta)
	
	move_and_slide()


func update_facing(target_pos: Vector2) -> void:
	direction = sign(target_pos.x - global_position.x)
	if direction != 0:
		visuals.scale.x = direction


func _on_damaged() -> void:
	set_state($States/HitState)


func _on_died() -> void:
	set_state($States/DeadState)
	return
