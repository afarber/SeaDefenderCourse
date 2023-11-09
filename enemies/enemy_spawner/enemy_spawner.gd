extends Marker2D

@export var facing_left = false

const Shark = preload("res://enemies/shark/shark.tscn")

func _on_timer_timeout():
	var shark_instance = Shark.instantiate()
	get_tree().current_scene.add_child(shark_instance)
	# set the new spawned shark position to the position of the marker cross
	shark_instance.global_position = global_position
	if facing_left:
		shark_instance.flip_direction()
