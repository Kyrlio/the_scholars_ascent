extends Area2D
class_name SwordUnlocker

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if GameState.has_ability("sword"):
		queue_free()
		return
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.unlocked_abitilities.append("sword")
		GameState.unlocked_abitilities.append("pogo")
		GameEvents.emit_ability_unlocked("sword")
		GameEvents.emit_ability_unlocked("pogo")
		GameEvents.emit_show_ability_popup("Sword", "You can now attack enemies by pressing X. You can also hit upwards and downwards (only while Todd is in the air).", sprite.texture )
		print("Compétence débloquée : ", "sword / pogo")
		
		# to show a popup
		#GameEvents.emit_ability_unlocked(ability_to_unlock)
		
		set_deferred("monitoring", false)
		queue_free.call_deferred()
