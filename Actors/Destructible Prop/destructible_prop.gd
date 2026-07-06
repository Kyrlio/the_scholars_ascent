extends Node2D
class_name DestructibleProp

@export var texture: Texture2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite : Sprite2D = $Sprite2D
@onready var loots: Node2D = %Loots
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if texture:
		sprite.texture = texture
	
	if health_component:
		health_component.died.connect(_on_died)


func _on_died() -> void:
	for loot in loots.get_children():
		if loot is Loot2D and loot.has_method("drop"):
			loot.drop()
	
	#collision_shape.set_deferred("disabled", true)
	# TODO : SFX -> AudioManager
	animation_player.play("destruction")
