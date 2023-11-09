extends AnimatedSprite2D

var can_shoot = true
var velocity = Vector2(0, 0)

const TURNING_TARGET = 2.0
var turning_timer = TURNING_TARGET
# if player looks left, the angle is 0
# if player looks right, the angle is PI
var start_angle = 0.0
var target_angle = 0.0

const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7
const Bullet = preload("res://player/player_bullet/player_bullet.tscn")

@onready var reload_timer = $ReloadTimer

func _process(delta):

	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()
	
	if turning_timer < TURNING_TARGET:
		turning_timer += delta

		# arrived at the target, stop the timer
		if turning_timer >= TURNING_TARGET:
			turning_timer = TURNING_TARGET
			start_angle = target_angle
			scale.x = 1
		else:
			# flip when passed half of the timer
			if turning_timer >= TURNING_TARGET / 2:
				flip_h = (target_angle == PI)
			var angle = lerp(start_angle, target_angle, turning_timer / TURNING_TARGET)
			scale.x = abs(cos(angle))
			print("UPDATED angle=%.2f -> target_angle=%.2f scale.x=%.2f flip_h=%s" % [angle, target_angle, scale.x, flip_h])
			
	if velocity.x > 0 and target_angle == PI:
		target_angle = 0.0
		turning_timer = 0.0
		print("STARTED start_angle=%.2f -> target_angle=%.2f scale.x=%.2f flip_h=%s" % [start_angle, target_angle, scale.x, flip_h])
	elif velocity.x < 0 and target_angle == 0.0:
		target_angle = PI
		turning_timer = 0.0
		print("STARTED start_angle=%.2f -> target_angle=%.2f scale.x=%.2f flip_h=%s" % [start_angle, target_angle, scale.x, flip_h])
	
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
