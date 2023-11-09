extends Area2D

var velocity = Vector2(1, 0)

@onready var sprite = $AnimatedSprite2D

const SPEED = 25

var points_value = 30

func _physics_process(delta):
	global_position += velocity * SPEED * delta

func _process(delta):
	if global_position.x > Global.SCREEN_BOUND_MAX_X or global_position.x < Global.SCREEN_BOUND_MIN_X:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("PlayerGroup"):
		Global.saved_people_count += 1
		GameEvent.emit_signal("update_people_count", Global.saved_people_count)
		Global.current_points += points_value
		GameEvent.emit_signal("update_points")
		queue_free()
	elif area.is_in_group("PlayerBulletGroup"):
		queue_free()

func flip_direction():
	velocity = -velocity
	sprite.flip_h = !sprite.flip_h
