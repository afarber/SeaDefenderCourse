extends Sprite2D

var velocity = Vector2(1, 0)
var move_speed = 150.0
var rotation_speed = 50

func _ready():
	var random_angle = deg_to_rad(randf_range(0, 360))
	velocity = velocity.rotated(random_angle)
	rotation_speed = randf_range(-70, 70)

func _physics_process(delta):
	global_position += velocity * move_speed * delta
	rotation_degrees += rotation_speed * delta
	move_speed = lerp(move_speed, 0.0, 6 * delta)
