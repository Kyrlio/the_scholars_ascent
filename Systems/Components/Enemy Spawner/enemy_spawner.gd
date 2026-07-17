extends Marker2D
class_name EnemySpawner

@export var enemy_definition: EnemyDefinition
@export var target_container_name: String = "Enemies"
@export var is_area_spawner: bool = false

@onready var screen_notifier: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var respawn_timer: Timer = $RespawnTimer

var active_enemy: CharacterBody2D = null
var spawner_id: String = ""


func _ready() -> void:
	if owner != null and owner.scene_file_path != "":
		spawner_id = owner.scene_file_path + "::" + str(owner.get_path_to(self))
	else:
		spawner_id = str(get_path())
	
	if not is_area_spawner:
		screen_notifier.screen_entered.connect(_on_screen_entered)
		respawn_timer.timeout.connect(_on_respawn_timer_timeout)


func _on_screen_entered() -> void:
	request_spawn_check()


func _on_respawn_timer_timeout() -> void:
	if screen_notifier.is_on_screen():
		request_spawn_check()


func request_spawn_check() -> void:
	call_deferred("_check_and_spawn")


func spawn() -> CharacterBody2D:
	return _check_and_spawn()


func _check_and_spawn() -> CharacterBody2D:
	if enemy_definition == null or enemy_definition.enemy_scene == null:
		return null
	if is_instance_valid(active_enemy):
		return active_enemy
	
	if spawner_id in GameState.defeated_enemies:
		return null
	
	active_enemy = enemy_definition.enemy_scene.instantiate()
	active_enemy.global_position = global_position
	
	if "enemy_id" in active_enemy:
		active_enemy.enemy_id = spawner_id
	
	active_enemy.tree_exited.connect(_on_enemy_removed)
	
	var container = get_tree().current_scene.find_child(target_container_name, true, false)
	if container:
		container.call_deferred("add_child", active_enemy)
	else:
		get_tree().current_scene.call_deferred("add_child", active_enemy)

	return active_enemy


func _on_enemy_removed() -> void:
	active_enemy = null
	if not is_area_spawner and enemy_definition.respawn_time > 0.0:
		respawn_timer.start(enemy_definition.respawn_time)
