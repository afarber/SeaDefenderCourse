extends AnimatedSprite2D
 
var can_shoot = true
var velocity = Vector2(0, 0)
 
const FLIP_DURATION = 0.5
var flip_seconds = FLIP_DURATION
var going_left = false
 
const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7
const Bullet = preload("res://player/player_bullet/player_bullet.tscn")
 
@onready var reload_timer = $ReloadTimer
 
func _process(delta):
 
	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()
	
	_flip_the_player(velocity.x, delta)
	
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
	
func _flip_the_player(velocity_x, delta):
	# if the flip animation is active
	if flip_seconds < FLIP_DURATION:
		flip_seconds += delta
 
		# completed flipping, stop the animation
		if flip_seconds >= FLIP_DURATION:
			flip_seconds = FLIP_DURATION
			scale.x = 1
		else:
			# flip to the moving direction when passed half of the timer
			if flip_seconds >= FLIP_DURATION / 2:
				flip_h = going_left
			# if player looks left, the angle is PI
			# if player looks right, the angle is 0
			var start_angle = 0.0 if going_left else PI
			var target_angle = PI if going_left else 0.0
			var angle = lerp(start_angle, target_angle, flip_seconds / FLIP_DURATION)
			scale.x = abs(cos(angle))
	else:
		# animation not active and moving right, but facing left
		if velocity_x > 0 and flip_h:
			going_left = false
			flip_seconds = 0.0
		# animation not active and moving left, but facing right
		elif velocity_x < 0 and !flip_h:
			going_left = true
			flip_seconds = 0.0
