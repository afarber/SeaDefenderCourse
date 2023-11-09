extends Sprite2D

@export var order_number = 1

const EMPTY_TEXTURE = preload("res://user_interface/people-count/person_empty_ui.png")
const FULL_TEXTURE = preload("res://user_interface/people-count/person_ui.png")

func _process(delta):
	texture = FULL_TEXTURE if Global.saved_people_count >= order_number else EMPTY_TEXTURE
