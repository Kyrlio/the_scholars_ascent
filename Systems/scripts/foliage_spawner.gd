extends TileMapLayer
class_name GrassSpawner

@export var grass_scene: PackedScene
@export var vines_scene: PackedScene


func _ready() -> void:
	generate_grass()
	generate_vines()


func generate_grass() -> void:
	var used_cells := get_used_cells()
	
	for cell_pos in used_cells:
		var cell_above = cell_pos + Vector2i(0, -1)
		
		if get_cell_source_id(cell_above) != -1:
			continue
		
		var tile_data: TileData = get_cell_tile_data(cell_pos)
		if tile_data and tile_data.get_custom_data("type") == "grass_valid":
			var world_pos: Vector2 = map_to_local(cell_pos)
			
			_spawn_grass(world_pos + Vector2(-4, -8))
			_spawn_grass(world_pos + Vector2(4, -8))


func generate_vines() -> void:
	var used_cells := get_used_cells()
	
	for cell_pos in used_cells:
		var tile_data: TileData = get_cell_tile_data(cell_pos)
		if tile_data and tile_data.get_custom_data("type2") == "vine_valid":
			var world_pos: Vector2 = map_to_local(cell_pos)
			_spawn_vine(world_pos + Vector2(0, 8))


func _spawn_grass(spawn_position: Vector2) -> void:
	if randf_range(0.0, 1.0) > 0.8:
		return
	
	var props = get_tree().get_nodes_in_group("no_grass")
	for prop in props:
		if prop.global_position.distance_to(spawn_position) < 16.0:
			return
	
	var grass_instance: Grass = grass_scene.instantiate()
	grass_instance.global_position = spawn_position
	
	add_child.call_deferred(grass_instance)


func _spawn_vine(spawn_position: Vector2) -> void:
	if randf_range(0.0, 1.0) > 0.3:
		return
	
	var vine_instance: Vine = vines_scene.instantiate()
	vine_instance.global_position = spawn_position
	
	add_child.call_deferred(vine_instance)
