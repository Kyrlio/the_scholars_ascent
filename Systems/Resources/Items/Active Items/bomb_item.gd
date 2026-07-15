extends ActiveItem
class_name BombItem

@export var bomb_scene: PackedScene

func use(player: Player) -> void:
	var bomb = bomb_scene.instantiate()
	bomb.global_position = player.global_position + Vector2(10, -10)
	var dir := player.get_facing_direction()
	bomb.linear_velocity = Vector2(dir * 250, -150)
	player.get_tree().current_scene.add_child.call_deferred(bomb)
