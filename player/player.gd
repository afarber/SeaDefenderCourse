extends AnimatedSprite2D

var can_shoot = true
var velocity = Vector2(0, 0)

const TURNING_START = 1000
var is_turning_left = false
var is_turning_right = false
var turning_timer = TURNING_START

const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7
const Bullet = preload("res://player/player_bullet/player_bullet.tscn")

@onready var reload_timer = $ReloadTimer

func _process(delta):
	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()

	if is_turning_left:
		turning_timer -= delta
		scale.x = 0.5 #turning_timer / TURNING_START
		if turning_timer <= 0:
			is_turning_left = false
			is_turning_right = false
			flip_h = true
			scale.x = 1
	elif is_turning_right:
		turning_timer -= delta
		scale.x = 0.5 #turning_timer / TURNING_START
		if turning_timer <= 0:
			is_turning_left = false
			is_turning_right = false
			flip_h = false
			scale.x = 1
	
	if velocity.x > 0 and !is_turning_right:
		is_turning_left = false
		is_turning_right = true
		turning_timer = TURNING_START
	elif velocity.x < 0 and !is_turning_left:
		is_turning_left = true
		is_turning_right = false
		turning_timer = TURNING_START
		
	# TODO
	#scale.x = .5
	
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
