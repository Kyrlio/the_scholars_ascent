extends Node
class_name EnemyState

var context: CharacterBody2D
var previous_state: EnemyState

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func get_hurt(_damage: int) -> void:
	pass
