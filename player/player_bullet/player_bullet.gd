extends AnimatedSprite2D

var velocity = Vector2(1, 0)

const SPEED = 300

func _physics_process(delta):
	global_position += velocity * SPEED * delta
