extends AnimatedSprite2D

var can_shoot = true
var velocity = Vector2(0, 0)

const TURNING_TARGET = 2.0
var turning_timer = TURNING_TARGET
# if player looks left, the angle is 0
# if player looks right, the angle is PI
var target_angle = 0.0

const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7
const Bullet = preload("res://player/player_bullet/player_bullet.tscn")

@onready var reload_timer = $ReloadTimer

func _process(delta):

	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()
	
	# if the timer is active
	if turning_timer < TURNING_TARGET:
		turning_timer += delta

		# completed turning, stop the timer
		if turning_timer >= TURNING_TARGET:
			turning_timer = TURNING_TARGET
			scale.x = 1
		else:
			# flip to the moving direction when passed half of the timer
			if turning_timer >= TURNING_TARGET / 2:
				flip_h = (target_angle == PI)
			var start_angle = PI if target_angle == 0.0 else 0.0
			var angle = lerp(start_angle, target_angle, turning_timer / TURNING_TARGET)
			scale.x = abs(cos(angle))
			print("UPDATED angle=%.2f -> target_angle=%.2f scale.x=%.2f flip_h=%s" % [angle, target_angle, scale.x, flip_h])
	else:
		# timer not active and moving right, but facing left
		if velocity.x > 0 and flip_h:
			target_angle = 0.0
			turning_timer = 0.0
			print("STARTED target_angle=%.2f scale.x=%.2f flip_h=%s" % [target_angle, scale.x, flip_h])
		# timer not active and moving left, but facing right
		elif velocity.x < 0 and !flip_h:
			target_angle = PI
			turning_timer = 0.0
			print("STARTED target_angle=%.2f scale.x=%.2f flip_h=%s" % [target_angle, scale.x, flip_h])
	
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
