extends Node2D

@export_group("Light Flicker")
@export var noise_speed: float = 150.
@export var energy_flicker_amount: float = 0.25
@export var scale_flicker_amount: float = 0.05
@export var base_energy: float = 1.0

@export var point_light: PointLight2D

var noise: FastNoiseLite = FastNoiseLite.new()
var time_passed: float = 0.0


func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.05


func _process(delta: float) -> void:
	time_passed += delta * noise_speed
	
	var noise_value = noise.get_noise_1d(time_passed)
	
	point_light.energy = base_energy + (noise_value * energy_flicker_amount)
	
	point_light.texture_scale = 1.0 + (noise_value * scale_flicker_amount)
