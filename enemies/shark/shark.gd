extends Area2D

const SPEED = 50
const MOVEMENT_FREQUENCY = 0.15
const MOVEMENT_AMPLITUDE = 0.5

var velocity = Vector2(1, 0)
var points_value = 25

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	velocity.y = sin(global_position.x * MOVEMENT_FREQUENCY) * MOVEMENT_AMPLITUDE
	global_position += velocity * SPEED * delta

func _process(delta):
	if global_position.x > Global.SCREEN_BOUND_MAX_X or global_position.x < Global.SCREEN_BOUND_MIN_X:
		queue_free()

func _on_area_entered(area):
	# Hit by a bullet, remove the shark and bullet
	if area.is_in_group("PlayerBulletGroup"):
		Global.current_points += points_value
		GameEvent.emit_signal("update_points")
		# the parent of the area is player_bullet
		area.queue_free()
		queue_free()
	# Touched the player, send the game over signal
	elif area.is_in_group("PlayerGroup"):
		GameEvent.emit_signal("game_over")
	
func flip_direction():
	velocity = -velocity
	sprite.flip_h = !sprite.flip_h
