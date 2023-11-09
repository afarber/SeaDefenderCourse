extends Node2D

const Shark = preload("res://enemies/shark/shark.tscn")
const Person = preload("res://person/person.tscn")

@onready var left = $Left
@onready var right = $Right

func _on_spawn_enemy_timer_timeout():
	var available_spawn_points = range(1, 5)
	available_spawn_points.shuffle()
	while available_spawn_points.size() > 0:
		var shark_instance = Shark.instantiate()
		var selected_spawn_point_number = available_spawn_points.pop_front()
		spawn_instance(shark_instance, selected_spawn_point_number)

func spawn_instance(enemy_or_person_instance, selected_spawn_point_number):
	var selected_side_node = left if bool(randi_range(0, 1)) else right
	var selected_spawn_point = selected_side_node.get_node(str(selected_spawn_point_number))
	var spawn_position = selected_spawn_point.global_position

	enemy_or_person_instance.global_position = spawn_position
	get_tree().current_scene.add_child(enemy_or_person_instance)

	if selected_side_node == right:
		enemy_or_person_instance.flip_direction()

func _on_spawn_person_timer_timeout():
	var person_instance = Person.instantiate()
	var selected_spawn_point_number = randi_range(1, 4)
	spawn_instance(person_instance, selected_spawn_point_number)
