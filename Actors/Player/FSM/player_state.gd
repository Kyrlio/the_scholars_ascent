extends Node
class_name PlayerState

@onready var idle_state: Node = $IdleState
@onready var run_state: Node = $RunState
@onready var jump_state: Node = $JumpState
@onready var fall_state: Node = $FallState
@onready var wall_slide_state: Node = $WallSlideState
@onready var roll_state: Node = $RollState
@onready var ground_attack_state: Node = $GroundAttackState
@onready var air_attack_state: Node = $AirAttackState
@onready var hurt_state: Node = $HurtState
@onready var dead_state: Node = $DeadState
@onready var rest_state: Node = $RestState
@onready var show_item_state: Node = $ShowItemState

var context: Player
var previous_state: PlayerState


func enter() -> void:
	pass


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	pass


func handle_input(event: InputEvent) -> void:
	pass
