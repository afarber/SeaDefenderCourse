extends Area2D

var velocity = Vector2(1, 0)

const SPEED = 300

@onready var sprite = $AnimatedSprite2D

func _ready():
	rotation_degrees = randf_range(-7, 7)
	# use rotation and not rotation_degress, because the former is in radians
	velocity = velocity.rotated(rotation)

func _physics_process(delta):
	global_position += velocity * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func flip_direction():
	velocity = -velocity
	sprite.flip_h = !sprite.flip_h
