extends Stats
class_name StatsDecorator

var decorated_stats: Stats

func get_speed() -> float:
	if decorated_stats:
		return decorated_stats.speed
	else:
		return super()

func get_jump_velocity() -> float:
	if decorated_stats:
		return decorated_stats.jump_velocity
	else:
		return super()

func get_jump_gravity() -> float:
	if decorated_stats:
		return decorated_stats.jump_gravity
	else:
		return super()

func get_fall_gravity() -> float:
	if decorated_stats:
		return decorated_stats.fall_gravity
	else:
		return super()

func get_extra_jumps() -> int:
	if decorated_stats:
		return decorated_stats.extra_jumps
	else:
		return super()

func get_attack_damage() -> int:
	if decorated_stats:
		return decorated_stats.attack_damage
	else:
		return super()
