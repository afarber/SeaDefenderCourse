extends Area2D

var velocity = Vector2(1, 0)

@onready var sprite = $AnimatedSprite2D

const SPEED = 25
const SaveSound = preload("res://person/saving_person.ogg")
const DeathSound = preload("res://person/person_death.ogg")
const PointValuePopup = preload("res://user_interface/point-value-popup/point_value_popup.tscn")

var points_value = 30

enum State { DEFAULT, PAUSED }
var state = State.DEFAULT

func _ready():
	GameEvent.connect("pause_enemies", Callable(self, "_pause"))

func _physics_process(delta):
	if state == State.DEFAULT:
		global_position += velocity * SPEED * delta

func _process(delta):
	if global_position.x > Global.SCREEN_BOUND_MAX_X or global_position.x < Global.SCREEN_BOUND_MIN_X:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("PlayerGroup"):
		SoundManager.play_sound(SaveSound)
		instance_point_popup()
		Global.saved_people_count += 1
		GameEvent.emit_signal("update_people_count", Global.saved_people_count)
		Global.current_points += points_value
		GameEvent.emit_signal("update_points")
		queue_free()
	elif area.is_in_group("PlayerBulletGroup"):
		SoundManager.play_sound(DeathSound)
		area.queue_free()
		queue_free()

func flip_direction():
	velocity = -velocity
	sprite.flip_h = !sprite.flip_h

func instance_point_popup():
	var point_popup_instance = PointValuePopup.instantiate()
	point_popup_instance.global_position = global_position
	point_popup_instance.value = points_value
	get_tree().current_scene.add_child(point_popup_instance)

func _pause(pause):
	state = State.PAUSED if pause else State.DEFAULT
