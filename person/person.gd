extends Area2D

var velocity = Vector2(1, 0)

@onready var sprite = $AnimatedSprite2D

const SPEED = 25

func _physics_process(delta):
	global_position += velocity * SPEED * delta

func _on_area_entered(area):
	if area.is_in_group("PlayerGroup"):
		Global.saved_people_count += 1
		GameEvent.emit_signal("update_people_count", Global.saved_people_count)
		queue_free()
	elif area.is_in_group("PlayerBulletGroup"):
		queue_free()

func flip_direction():
	velocity = -velocity
	sprite.flip_h = !sprite.flip_h

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
