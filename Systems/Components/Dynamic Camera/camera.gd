extends Camera2D
class_name DynamicCamera


@export_group("Suivi du Joueur")
@export var target: Player
@export var follow_speed: float = 5.0
@export var lookahead_distance: float = 25.0
@export var lookahead_speed: float = 2.0

@export_group("Vertical Looking")
@export var look_delay: float = 0.5
@export var look_offset: float = 50.0

@export_group("Camera Shake (trauma)")
@export var max_offset: Vector2 = Vector2(30, 30)
@export var max_roll: float = 0.1
@export var trauma_reduction_rate: float = 1.0

var trauma: float = 0.0
var time: float = 0.0
var noise = FastNoiseLite.new()

var current_look_time: float = 0.0
var look_direction: float = 0.0
var current_lookahead: float = 0.0


func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.5
	position_smoothing_enabled = false
	
	GameEvents.camera_shake_requested.connect(add_trauma)


func _physics_process(delta: float) -> void:
	if target:
		_smooth_follow(delta)
	
	if trauma > 0:
		_apply_shake(delta)
	

func _smooth_follow(delta: float) -> void:
	var target_pos = target.global_position
	
	var facing_dir = target.get_facing_direction()
	var target_lookahead = facing_dir * lookahead_distance
	
	var lookahead_blend = 1.0 - exp(-lookahead_speed * delta)
	current_lookahead = lerp(current_lookahead, target_lookahead, lookahead_blend)
	
	target_pos.x += current_lookahead
	
	if Input.is_action_pressed("ui_up"):
		look_direction = -1.0
		current_look_time += delta
	elif Input.is_action_pressed("ui_down"):
		look_direction = 1.0
		current_look_time += delta
	else:
		current_look_time = 0.0
		look_direction = 0.0
	
	if current_look_time > look_delay:
		target_pos.y += look_direction * look_offset
	
	var blend_factor = 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(target_pos, blend_factor)


func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _apply_shake(delta: float) -> void:
	time += delta * 30.0
	trauma = max(trauma - trauma_reduction_rate * delta, 0.0)
	
	var shake_amount = trauma * trauma
	
	offset.x = max_offset.x * shake_amount * noise.get_noise_2d(time, 0.0)
	offset.y = max_offset.y * shake_amount * noise.get_noise_2d(0.0, time)
	rotation = max_roll * shake_amount * noise.get_noise_2d(time, time)
