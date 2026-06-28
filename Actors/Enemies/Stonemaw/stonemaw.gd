extends CharacterBody2D
class_name Stonemaw

@export var enemy_id: String = ""
@export var chase_speed: float = 80.0
@export var gravity: float = 500.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var states: Node = $States

@onready var vision_area: Area2D = %VisionArea2D
@onready var melee_area: Area2D = %MeleeArea2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = %HitboxComponent

@onready var ledge_detection_ray: RayCast2D = %LedgeDetectionRay
@onready var wall_detection_ray: RayCast2D = %WallDetectionRay


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
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if state:
		state.physics_update(delta)
	
	move_and_slide()

func update_facing() -> void:
	if direction != 0:
		visuals.scale.x = direction

func _on_damaged() -> void:
	set_state($States/HitState)

func _on_died() -> void:
	set_state($States/DeadState)
	return
