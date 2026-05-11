extends CanvasLayer


@export var tex_heart_full: Texture2D
@export var tex_heart_half: Texture2D
@export var tex_heart_empty: Texture2D

@onready var hearts = [%Heart1, %Heart2, %Heart3, %Heart4, %Heart5]
@onready var gold_label: Label = %GoldLabel

var previous_hp: int = -1
var total_gold: int = 0

func _ready() -> void:
	GameEvents.player_health_changed.connect(update_health_ui)
	GameEvents.gold_collected.connect(add_gold)
	
	for heart in hearts:
		heart.pivot_offset = heart.size / 2.0
	
	gold_label.text = str(GameState.total_gold)


func add_gold(_amount: int) -> void:
	#total_gold += amount
	gold_label.text = str(GameState.total_gold)
	
	var tw = create_tween()
	gold_label.scale = Vector2(1.5, 1.5)
	tw.tween_property(gold_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BOUNCE)


func update_health_ui(current_hp: int, max_hearts: int) -> void:
	if previous_hp != -1 and current_hp < previous_hp:
		var affected_heart_index = (previous_hp - 1) / 2
		
		if affected_heart_index >= 0 and affected_heart_index < hearts.size():
			juice_heart(hearts[affected_heart_index], Color.RED)
	
	elif previous_hp != -1 and current_hp > previous_hp:
		var affected_heart_index = (current_hp - 1) / 2
		
		if affected_heart_index < hearts.size():
			juice_heart(hearts[affected_heart_index], Color.GREEN)
	
	previous_hp = current_hp
	
	for i in range(hearts.size()):
		var heart = hearts[i]
		
		if i < max_hearts / 2.0 :
			heart.show()
		else:
			heart.hide()
		
		var heart_value = current_hp - (i * 2)
		
		if heart_value >= 2:
			heart.texture = tex_heart_full
		elif heart_value == 1:
			heart.texture = tex_heart_half
		else:
			heart.texture = tex_heart_empty


func juice_heart(heart: TextureRect, color: Color) -> void:
	var tw := create_tween().set_parallel(true)
	heart.z_index = 1
	
	heart.modulate = color
	tw.tween_property(heart, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_QUAD)
	
	heart.scale = Vector2(1.6, 1.6)
	tw.tween_property(heart, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await tw.finished
	
	heart.z_index = 0
