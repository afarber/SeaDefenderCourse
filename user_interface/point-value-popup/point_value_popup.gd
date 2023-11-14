extends Node2D

const SPEED = 15

var value = 0

@onready var label = $Label

func _ready():
	label.text = str(value)
	#rotation_degrees = randf_range(0, 360)

func _physics_process(delta):
	global_position.y -= SPEED * delta
	#rotation_degrees = lerp(rotation_degrees, 0.0, 18 * delta)
