extends Node

@export var scene_to_spawn: PackedScene
@export var initial_amount: int

var pool: Array = []

func _ready() -> void:
	for i in range(initial_amount):
		_create_new_node(true)


func _create_new_node(deferred: bool = false) -> Node:
	var node = scene_to_spawn.instantiate()
	if deferred:
		get_tree().current_scene.add_child.call_deferred(node)
	else:
		get_tree().current_scene.add_child(node)
	node.visible = false
	pool.append(node)
	return node


func spawn() -> Node:
	var node = null
	
	for i in len(pool):
		if pool[i].visible == false:
			node = pool[i]
			break
	
	if node == null:
		node = _create_new_node(false)
	
	return node
