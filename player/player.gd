extends Area2D

const OXYGEN_DECREASE_SPEED = 2.5
const OXYGEN_INCREASE_SPEED = 60
const OXYGEN_REFUEL_Y_POSITION = 38
const OXYGEN_REFUEL_MOVE_SPEED = 70
const MAX_X_POSITION = 248
const MIN_X_POSTION = 13
const MAX_Y_POSITION = 205
const MIN_Y_POSTION = OXYGEN_REFUEL_Y_POSITION
const ROTATION_STRENGTH = 15
const SPEED = Vector2(125, 90)
const BULLET_OFFSET = 7
const PIECE_COUNT = 10

const Bullet = preload("res://player/player_bullet/player_bullet.tscn")
const ShootSound = preload("res://player/player_bullet/player_shoot.ogg")
const DeathSound = preload("res://player/player_death.ogg")
const OxygenFullSound = preload("res://user_interface/oxygen-bar/full_oxygen_alert.ogg")
const ObjectPiece = preload("res://particles/object-piece/object_piece.tscn")
const PieceTexture = preload("res://player/player_pieces.png")

enum State { DEFAULT, PEOPLE_REFUEL, OXYGEN_REFUEL }
var state = State.DEFAULT

# can_shoot is false while reloading
var can_shoot = true
var velocity = Vector2(0, 0)
 
@onready var sprite = $AnimatedSprite2D
@onready var reload_timer = $ReloadTimer
@onready var decrease_people_timer = $DecreasePeopleTimer

func _ready():
	GameEvent.connect("full_crew_oxygen_refuel", Callable(self, "_full_crew_oxygen_refuel"))
	GameEvent.connect("less_people_oxygen_refuel", Callable(self, "_less_people_oxygen_refuel"))
	GameEvent.connect("game_over", Callable(self, "_game_over"))
	
func _process(delta):
	if state == State.DEFAULT:
		process_movement_input()
		direction_follows_input()
		process_shooting()
		lose_oxygen(delta)
		_death_when_oxygen_reaches_zero()
	elif state == State.OXYGEN_REFUEL:
		oxygen_refuel(delta)
	elif state == State.PEOPLE_REFUEL:
		pass

func _physics_process(delta):
	if state == State.DEFAULT:
		movement(delta)
		rotate_to_movement(delta)
	else:
		move_to_shore_line(delta)
	clamp_position()
	GameEvent.emit_signal("camera_follow_player", global_position.y)

func _on_reload_timer_timeout():
	can_shoot = true
	
func process_movement_input():
	velocity.x = Input.get_axis("move_left", "move_right")	
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity = velocity.normalized()

func direction_follows_input():
	# do not change direction so long as the player holds the shoot button -
	# to allow the player to move backwards and shoot at the sharks
	if Input.is_action_pressed("shoot"):
		return

	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func rotate_to_movement(delta):
	var rotation_target = 0
	
	if velocity.y == 0:
		rotation_target = velocity.x * ROTATION_STRENGTH
	elif !sprite.flip_h:
		rotation_target = velocity.y * ROTATION_STRENGTH
	else:
		rotation_target = -velocity.y * ROTATION_STRENGTH

	rotation_degrees = lerp(rotation_degrees, rotation_target, 15 * delta)

func process_shooting():
	# can_shoot is changed by the reload timer to prevent spamming the shoot key
	if Input.is_action_pressed("shoot") and can_shoot:
		var bullet_instance = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)

		SoundManager.play_sound(ShootSound)

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
		sprite.play("default")
		SoundManager.play_sound(OxygenFullSound)
		GameEvent.emit_signal("pause_enemies", false)

func _death_when_oxygen_reaches_zero():
	if Global.oxygen_level <= 0:
		death()

func death():
	SoundManager.play_sound(DeathSound)
	GameEvent.emit_signal("game_over")
	GameEvent.emit_signal("pause_enemies", true)
	instance_player_pieces()

func instance_player_pieces():
	for i in range(PIECE_COUNT):
		var object_piece_instance = ObjectPiece.instantiate()
		object_piece_instance.texture = PieceTexture
		object_piece_instance.hframes = PIECE_COUNT
		object_piece_instance.frame = i
		object_piece_instance.global_position = global_position
		get_tree().current_scene.add_child(object_piece_instance)

func movement(delta):
	global_position += velocity * SPEED * delta

func clamp_position():
	global_position.x = clamp(global_position.x, MIN_X_POSTION, MAX_X_POSITION)
	global_position.y = clamp(global_position.y, MIN_Y_POSTION, MAX_Y_POSITION)

func move_to_shore_line(delta):
	var move_speed = OXYGEN_REFUEL_MOVE_SPEED * delta
	global_position.y = move_toward(global_position.y, OXYGEN_REFUEL_Y_POSITION, move_speed)

func remove_one_person():
	if Global.saved_people_count > 0:
		Global.saved_people_count -= 1
		GameEvent.emit_signal("update_people_count", Global.saved_people_count)

# called by the signal full_crew_oxygen_refuel when touching the top area
func _full_crew_oxygen_refuel():
	state = State.PEOPLE_REFUEL
	sprite.play("flash")
	decrease_people_timer.start()
	GameEvent.emit_signal("pause_enemies", true)
	GameEvent.emit_signal("kill_all_enemies")

# called by the signal less_people_oxygen_refuel when touching the top area
func _less_people_oxygen_refuel():
	state = State.OXYGEN_REFUEL
	sprite.play("flash")
	# punish the player for refueling oxygen with a not full crew by removing 1 person
	remove_one_person()
	GameEvent.emit_signal("pause_enemies", true)

func _on_decrease_people_timer_timeout():
	remove_one_person()
	if Global.saved_people_count <= 0:
		decrease_people_timer.stop()
		state = State.OXYGEN_REFUEL

func _game_over():
	queue_free()
