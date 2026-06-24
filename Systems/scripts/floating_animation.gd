extends Node2D

@export var speed: float = 2.0
@export var amplitude: float = 2.0

@onready var target: Node2D = get_parent()

var base_y: float
var time: float = 0.0

func _ready() -> void:
	base_y = target.position.y

func _physics_process(delta: float) -> void:
	time += delta * speed
	target.position.y = base_y + sin(time) * amplitude
