extends Node2D
class_name DestructibleProp

@export var prop_id: String = ""
@export var texture: Texture2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var sprite : Sprite2D = $Sprite2D
@onready var loots: Node2D = %Loots
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	prop_id = GameState.get_unique_prop_id(self)
	
	if prop_id != "" and prop_id in GameState.destroyed_props:
		queue_free()
		return
	
	if texture:
		sprite.texture = texture
	
	if health_component:
		health_component.died.connect(_on_died)


func _on_died() -> void:
	if prop_id != "" and not prop_id in GameState.destroyed_props:
		GameState.destroyed_props.append(prop_id)
		
	for loot in loots.get_children():
		if loot is Loot2D and loot.has_method("drop"):
			loot.drop()
	
	#collision_shape.set_deferred("disabled", true)
	# TODO : SFX -> AudioManager
	animation_player.play("destruction")
