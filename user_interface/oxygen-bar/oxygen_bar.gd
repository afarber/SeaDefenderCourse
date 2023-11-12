extends Node2D

@onready var progress_bar = $TextureProgress

const SCALE = "scale"
const ROTATION = "rotation"
const SHAKE_VALUES = {
	2.0: {SCALE: 1.6, ROTATION: 25},
	5.0: {SCALE: 1.5, ROTATION: 20},
	7.0: {SCALE: 1.4, ROTATION: 15},
	10.0: {SCALE: 1.35, ROTATION: 10},
	15.0: {SCALE: 1.3, ROTATION: 7},
	25.0: {SCALE: 1.25, ROTATION: 5},
}

var previous_amount = 0

func _process(delta):
	progress_bar.value = Global.oxygen_level

	var amount_rounded = round(Global.oxygen_level)
	if  amount_rounded == previous_amount:
		return
	previous_amount = amount_rounded

	if  SHAKE_VALUES.has(amount_rounded):
		var scale_value = SHAKE_VALUES[amount_rounded][SCALE]
		var rotation_value = SHAKE_VALUES[amount_rounded][ROTATION]
		alert(scale_value, rotation_value)

func _physics_process(delta):
	scale = lerp(scale, Vector2(1.0, 1.0), 6 * delta)
	rotation_degrees = lerp(rotation_degrees, 0.0, 6 * delta)

func alert(scale_value, rotation_value):
	scale = Vector2(scale_value, scale_value)
	rotation_degrees = randf_range(-rotation_value, rotation_value)
