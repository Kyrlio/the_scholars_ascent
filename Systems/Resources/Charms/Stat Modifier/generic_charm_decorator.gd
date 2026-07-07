extends StatsDecorator
class_name GenericCharmDecorator

@export var speed_multiplier: float = 1.0
@export var jump_multiplier: float = 1.0
@export var attack_multiplier: float = 1.0
@export var fall_multiplier: float = 1.0
@export var extra_jumps_bonus: int = 0


func get_speed() -> float:
	return decorated_stats.speed * speed_multiplier if decorated_stats else super()

func get_jump_velocity() -> float:
	return decorated_stats.jump_velocity * jump_multiplier if decorated_stats else super()

func get_fall_gravity() -> float:
	return decorated_stats.fall_gravity * fall_multiplier if decorated_stats else super()

func get_extra_jumps() -> int:
	return (decorated_stats.extra_jumps + extra_jumps_bonus) if decorated_stats else super()

func get_attack_damage() -> int:
	if decorated_stats:
		return int(decorated_stats.get_attack_damage() * attack_multiplier)
	else:
		return super()
