extends Area2D

var velocity = Vector2(1, 0)

const SPEED = 25

func _physics_process(delta):
	global_position += velocity * SPEED * delta

func _on_area_entered(area):
	if area.is_in_group("PlayerGroup"):
		# increase crew counter
		queue_free()
	elif area.is_in_group("PlayerBulletGroup"):
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
