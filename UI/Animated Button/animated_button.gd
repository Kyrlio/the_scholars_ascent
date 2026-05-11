extends Button
class_name AnimatedButton

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var tween: Tween

func _ready() -> void:
	nine_patch_rect.hide()
	
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	mouse_entered.connect(_on_focus_entered)
	mouse_exited.connect(_on_focus_exited)


func _on_focus_entered() -> void:
	nine_patch_rect.show()
	animation_player.play("default")
	
	#if tween != null:
		#tween.stop()
	#tween = create_tween()
	#tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_focus_exited() -> void:
	nine_patch_rect.hide()
	animation_player.stop()
	
	#if tween != null:
		#tween.stop()
	#tween = create_tween()
	#tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
