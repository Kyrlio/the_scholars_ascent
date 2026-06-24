extends Area2D
class_name WaterBall

@export var speed: float = 200.0

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	visible = false
	collision_shape.set_deferred("disabled", true)
	
	if hitbox_component:
		hitbox_component.get_node("CollisionShape2D").set_deferred("disabled", true)
		hitbox_component.hit_hurtbox.connect(_on_hitbox_hit)
	
	body_entered.connect(_on_body_entered)


func start(pos: Vector2, dir: Vector2) -> void:
	global_position = pos + Vector2(2, -8)
	rotation = dir.angle()
	visible = true
	reset_physics_interpolation()
	
	collision_shape.set_deferred("disabled", false)
	if hitbox_component:
		hitbox_component.get_node("CollisionShape2D").set_deferred("disabled", false)


func _physics_process(delta: float) -> void:
	if not visible:
		return
	
	position += transform.x * speed * delta


func _on_hitbox_hit(_hurtbox: HurtboxComponent) -> void:
	if not visible:
		return
	
	_deactivate()


func _on_body_entered(_body: Node2D) -> void:
	if not visible:
		return
	
	_deactivate()


func _deactivate() -> void:
	visible = false
	collision_shape.set_deferred("disabled", true)
	if hitbox_component:
		hitbox_component.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# TODO : Impact particles
