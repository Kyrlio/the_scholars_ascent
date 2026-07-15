extends ActiveItem
class_name BombItem

@export var bomb_scene: PackedScene
@export var throw_force: Vector2 = Vector2(325, -250)

func use(player: Player) -> void:
	if bomb_scene == null:
		return
	
	var bomb: Bomb = bomb_scene.instantiate()
	bomb.global_position = player.global_position + Vector2(1, -10)
	var dir := player.get_facing_direction() 
	bomb.linear_velocity = Vector2(dir * throw_force.x, throw_force.y)
	player.get_tree().current_scene.add_child.call_deferred(bomb)
