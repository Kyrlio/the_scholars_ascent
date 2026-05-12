extends Resource
class_name Stats

@export var speed: float = 125.0 : set = set_speed, get = get_speed
@export var jump_velocity: float = -275.0 : set = set_jump_velocity, get = get_jump_velocity
@export var jump_gravity: float = 900.0 : set = set_jump_gravity, get = get_jump_gravity
@export var fall_gravity: float = 1000.0 : set = set_fall_gravity, get = get_fall_gravity

func set_speed(value: float) -> void: speed = value
func get_speed() -> float: return speed

func set_jump_velocity(value: float) -> void: jump_velocity = value
func get_jump_velocity() -> float: return jump_velocity

func set_jump_gravity(value: float) -> void: jump_gravity = value
func get_jump_gravity() -> float: return jump_gravity

func set_fall_gravity(value: float) -> void: fall_gravity = value
func get_fall_gravity() -> float: return fall_gravity
