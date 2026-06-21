extends Area2D
class_name AbilityUnlocker

## Example : sword, wall_slide, wall_jump, roll, etc...
@export var ability_to_unlock: String = "" 
@export var ability_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if GameState.has_ability(ability_to_unlock):
		queue_free()
		return
	
	if ability_texture:
		sprite.texture = ability_texture
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.unlocked_abitilities.append(ability_to_unlock)
		print("Compétence débloquée : ", ability_to_unlock)
		
		# to show a popup
		#GameEvents.emit_ability_unlocked(ability_to_unlock)
		
		set_deferred("monitoring", false)
		queue_free.call_deferred()
