extends Area2D
class_name ArenaArea

const BAT_SCENE = preload("uid://b1ttmwn8g2yb1")

@export var arena_id: String = ""
@export var enemy_spawners: Array[EnemySpawner] = []

@onready var right_trapdoor: Trapdoor = $RightTrapdoor
@onready var left_trapdoor: Trapdoor = $LeftTrapdoor

var enemy_count: int = -1
var actual_arena_id: String = ""

func _ready() -> void:
	actual_arena_id = GameState.get_unique_arena_id(self)
	
	if actual_arena_id in GameState.completed_arenas:
		# L'arène a déjà été terminée, on la laisse ouverte et on ne surveille plus le joueur
		right_trapdoor.activate()
		left_trapdoor.activate()
		set_deferred("monitoring", false)
	else:
		right_trapdoor.activate()
		left_trapdoor.activate()
		enemy_count = enemy_spawners.size()
		#GameEvents.open_arena_requested.connect(_on_open_arena_requested)


func spawn_enemies() -> void:
	var scene_root := get_tree().current_scene
	if not scene_root: return
	
	enemy_count = 0
	for spawner in enemy_spawners:
		if spawner:
			var enemy = spawner.spawn()
			if enemy:
				enemy_count += 1
				if enemy.has_signal("died"):
					enemy.died.connect(_on_enemy_died)
				else:
					var health_component: HealthComponent = enemy.get_node_or_null("HealthComponent")
					if health_component and health_component.has_signal("died"):
						health_component.died.connect(_on_enemy_died)
					else:
						enemy.tree_exited.connect(_on_enemy_died)
	
	if enemy_count <= 0:
		right_trapdoor.activate()
		left_trapdoor.activate()
		if not actual_arena_id in GameState.completed_arenas:
			GameState.completed_arenas.append(actual_arena_id)

func _on_body_entered(body: Node2D) -> void:
	set_deferred("monitoring", false)
	right_trapdoor.deactivate()
	left_trapdoor.deactivate()
	
	await get_tree().create_timer(0.75).timeout
	
	spawn_enemies()

func _on_enemy_died() -> void:
	enemy_count -= 1
	if enemy_count <= 0:
		right_trapdoor.activate()
		left_trapdoor.activate()
		if not actual_arena_id in GameState.completed_arenas:
			GameState.completed_arenas.append(actual_arena_id)
