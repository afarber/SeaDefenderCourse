extends AnimatedSprite2D

var can_shoot = true
var velocity = Vector2(0, 0)

const TURNING_START = 1
var turning_timer = TURNING_START
# if player looks left, the angle is 0
# if player looks right, the angle is PI
var current_angle = 0
var target_angle = 0

const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7
const Bullet = preload("res://player/player_bullet/player_bullet.tscn")

@onready var reload_timer = $ReloadTimer

func _process(delta):

	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()
	
	if turning_timer > 0:
		turning_timer -= delta
		print("Updated turning_timer=%f" % turning_timer)
		# arrive at the target, stop the timer
		if turning_timer <= 0:
			turning_timer == 0
			current_angle = target_angle
			scale.x = 1
		else:
			current_angle = target_angle - turning_timer / TURNING_START
			scale.x = cos(current_angle)
	
	if velocity.x > 0 and current_angle == PI:
		target_angle = 0
		turning_timer = TURNING_START
		print("Started turning_timer=%f" % turning_timer)
	elif velocity.x < 0 and current_angle == 0:
		target_angle = PI
		turning_timer = TURNING_START
		print("Started turning_timer=%f" % turning_timer)
	
	if Input.is_action_pressed("shoot") and can_shoot:
		var bullet_instance = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)
		if flip_h:
			bullet_instance.flip_direction()
			bullet_instance.global_position = global_position - Vector2(BULLET_OFFSET, 0)
		else:
			bullet_instance.global_position = global_position + Vector2(BULLET_OFFSET, 0)
			
		can_shoot = false
		reload_timer.start()
	
func _physics_process(delta):
	global_position += velocity * SPEED * delta
	
func _on_reload_timer_timeout():
	can_shoot = true
