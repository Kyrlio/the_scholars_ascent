extends CharacterBody2D
class_name Slime

@export var enemy_id: String = ""
@export var jump_horizontal_speed: float = 45.0
@export var jump_vertical_speed: float = -175.0
@export var gravity: float = 500.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var vision_area: Area2D = $VisionArea2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals: Node2D = $Visuals
@onready var ledge_detection_ray: RayCast2D = %LedgeDetectionRay
@onready var wall_detection_ray: RayCast2D = %WallDetectionRay
@onready var states: Node = $States
@onready var sprite: Sprite2D = $Visuals/Sprite2D

@onready var state: EnemyState : set = set_state

var direction: float = 1.0
var is_dead: bool = false
var tween: Tween

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
	
	set_state($States/PatrolState)


func set_state(new_state: EnemyState) -> void:
	if state:
		state.exit()
		new_state.previous_state = state
	state = new_state
	state.enter()


func _physics_process(delta: float) -> void:
	if is_dead: return
	
	var was_on_floor = is_on_floor()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
	
	if state:
		state.physics_update(delta)
	
	move_and_slide()
	
	if not was_on_floor and is_on_floor():
		apply_squish(1.3, 0.7)
	elif was_on_floor and not is_on_floor() and velocity.y < 0:
		apply_squish(0.7, 1.3)


func update_facing() -> void:
	if direction != 0:
		visuals.scale.x = direction


func _on_damaged() -> void:
	set_state($States/HitState)


func _on_died() -> void:
	set_state($States/DeadState)
	return


func apply_squish(squish_x: float, squish_y: float) -> void:
	sprite.scale = Vector2(squish_x, squish_y)
	
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.35)
