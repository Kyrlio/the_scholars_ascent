extends Resource
class_name Stats

@export var speed: float = 125.0 : set = set_speed, get = get_speed
@export var jump_velocity: float = -275.0 : set = set_jump_velocity, get = get_jump_velocity
@export var jump_gravity: float = 900.0 : set = set_jump_gravity, get = get_jump_gravity
@export var fall_gravity: float = 1000.0 : set = set_fall_gravity, get = get_fall_gravity
@export var extra_jumps: int = 0 : set = set_extra_jumps, get = get_extra_jumps

@export_group("Water Ball")
@export var max_water_ammo: int = 3 : set = set_max_water_ammo, get = get_max_water_ammo
@export var ammo_regen_time: float = 2.0 : set = set_ammo_regen_time, get = get_ammo_regen_time

func set_speed(value: float) -> void: speed = value
func get_speed() -> float: return speed

func set_jump_velocity(value: float) -> void: jump_velocity = value
func get_jump_velocity() -> float: return jump_velocity

func set_jump_gravity(value: float) -> void: jump_gravity = value
func get_jump_gravity() -> float: return jump_gravity

func set_fall_gravity(value: float) -> void: fall_gravity = value
func get_fall_gravity() -> float: return fall_gravity

func set_extra_jumps(value: int) -> void: extra_jumps = value
func get_extra_jumps() -> int: return extra_jumps

func set_max_water_ammo(value: int) -> void: max_water_ammo = value
func get_max_water_ammo() -> int: return max_water_ammo

func set_ammo_regen_time(value: float) -> void: ammo_regen_time = value
func get_ammo_regen_time() -> float: return ammo_regen_time
