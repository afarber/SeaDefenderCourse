extends Sprite2D

@export var order_number = 1

const EMPTY_TEXTURE = preload("res://user_interface/people-count/person_empty_ui.png")
const FULL_TEXTURE = preload("res://user_interface/people-count/person_ui.png")

func _ready():
	GameEvent.connect("update_people_count", Callable(self, "_update"))
	
func _update(saved_people_count):
	texture = FULL_TEXTURE if saved_people_count >= order_number else EMPTY_TEXTURE
