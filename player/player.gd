extends Area2D

const FLIP_DURATION = 0.5
const OXYGEN_DECREASE_SPEED = 2.5
const OXYGEN_INCREASE_SPEED = 60
const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7

const Bullet = preload("res://player/player_bullet/player_bullet.tscn")

enum State { DEFAULT, PEOPLE_REFUEL, LESS_PEOPLE_REFUEL }
var state = State.DEFAULT

var can_shoot = true
var velocity = Vector2(0, 0)
var flip_seconds = FLIP_DURATION
var going_left = false
 
@onready var sprite = $AnimatedSprite2D
@onready var reload_timer = $ReloadTimer

func _ready():
	GameEvent.connect("full_crew_oxygen_refuel", Callable(self, "_full_crew_oxygen_refuel"))
	GameEvent.connect("less_people_oxygen_refuel", Callable(self, "_less_people_oxygen_refuel"))
 
func _process(delta):
	if state == State.DEFAULT:
		process_movement_input()
		direction_follows_input(velocity.x, delta)
		process_shooting()
		lose_oxygen(delta)
	elif state == State.LESS_PEOPLE_REFUEL:
		oxygen_refuel(delta)
	elif state == State.PEOPLE_REFUEL:
		oxygen_refuel(delta)

func _physics_process(delta):
	if state == State.DEFAULT:
		movement(delta)

func _on_reload_timer_timeout():
	can_shoot = true
	
func process_movement_input():
	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()

func direction_follows_input(velocity_x, delta):
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
				sprite.flip_h = going_left
			# if player looks left, the angle is PI
			# if player looks right, the angle is 0
			var start_angle = 0.0 if going_left else PI
			var target_angle = PI if going_left else 0.0
			var angle = lerp_angle(start_angle, target_angle, flip_seconds / FLIP_DURATION)
			scale.x = abs(cos(angle))
	else:
		# animation not active and moving right, but facing left
		if velocity_x > 0 and sprite.flip_h:
			going_left = false
			flip_seconds = 0.0
		# animation not active and moving left, but facing right
		elif velocity_x < 0 and !sprite.flip_h:
			going_left = true
			flip_seconds = 0.0

func process_shooting():
	if Input.is_action_pressed("shoot") and can_shoot:
		var bullet_instance = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)
		if sprite.flip_h:
			bullet_instance.flip_direction()
			bullet_instance.global_position = global_position - Vector2(BULLET_OFFSET, 0)
		else:
			bullet_instance.global_position = global_position + Vector2(BULLET_OFFSET, 0)
			
		can_shoot = false
		reload_timer.start()

func lose_oxygen(delta):
	Global.oxygen_level = move_toward(Global.oxygen_level, 0, OXYGEN_DECREASE_SPEED * delta)

func oxygen_refuel(delta):
	Global.oxygen_level += OXYGEN_INCREASE_SPEED * delta
	if Global.oxygen_level > 99:
		state = State.DEFAULT

func movement(delta):
	global_position += velocity * SPEED * delta

func _full_crew_oxygen_refuel():
	state = State.PEOPLE_REFUEL

func _less_people_oxygen_refuel():
	state = State.LESS_PEOPLE_REFUEL
