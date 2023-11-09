extends AnimatedSprite2D

var velocity = Vector2(0, 0)
const SPEED = Vector2(125, 90)
const Bullet = preload("res://player/player_bullet/player_bullet.tscn")

func _process(delta):
	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	
	velocity = velocity.normalized()
	
	if velocity.x > 0:
		flip_h = false
	elif velocity.x < 0:
		flip_h = true
		
	#scale.x = .5
	if Input.is_action_pressed("shoot"):
		var bullet_instance = Bullet.instantiate()
		bullet_instance.global_position = global_position
		get_tree().current_scene.add_child(bullet_instance)

	
func _physics_process(delta):
	global_position += velocity * SPEED * delta
	
