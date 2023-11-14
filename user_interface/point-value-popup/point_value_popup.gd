extends Node2D

var value = 0

@onready var label = $Label

func _ready():
	label.text = str(value)
