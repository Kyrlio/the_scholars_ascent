extends StaticBody2D
class_name DestructiblePlatform

enum PlatformState { NORMAL, BREAKING, BROKEN }
var current_state: PlatformState = PlatformState.NORMAL

@onready var collider: CollisionShape2D = $Collider
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detector: Area2D = $Detector


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	_switch_state(PlatformState.NORMAL)


func _physics_process(delta: float) -> void:
	if current_state == PlatformState.NORMAL:
		_check_for_player()


func _switch_state(next_state: PlatformState) -> void:
	current_state = next_state
	
	match next_state:
		PlatformState.NORMAL:
			collider.set_deferred("disabled", false)
			animation_player.play("normal")
		
		PlatformState.BREAKING:
			animation_player.play("breaking")
		
		PlatformState.BROKEN:
			collider.set_deferred("disabled", true)
			animation_player.play("broken")


func _check_for_player() -> void:
	var bodies = detector.get_overlapping_bodies()
	
	for body in bodies:
		if body is Player and body.is_on_floor():
			_switch_state(PlatformState.BREAKING)
			break


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "breaking":
		_switch_state(PlatformState.BROKEN)
	elif anim_name == "broken":
		_switch_state(PlatformState.NORMAL)
