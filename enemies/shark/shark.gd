extends Area2D

const SPEED = 50
const PIECE_COUNT = 2
const MOVEMENT_FREQUENCY = 0.15
const MOVEMENT_AMPLITUDE = 0.5

const DeathSound = preload("res://enemies/shark/shark_death.ogg")
const ObjectPiece = preload("res://particles/object-piece/object_piece.tscn")

var velocity = Vector2(1, 0)
var points_value = 25

enum State { DEFAULT, PAUSED }
var state = State.DEFAULT

@onready var sprite = $AnimatedSprite2D

func _ready():
	GameEvent.connect("pause_enemies", Callable(self, "_pause"))

func _physics_process(delta):
	if state == State.DEFAULT:
		velocity.y = sin(global_position.x * MOVEMENT_FREQUENCY) * MOVEMENT_AMPLITUDE
		global_position += velocity * SPEED * delta

func _process(delta):
	if global_position.x > Global.SCREEN_BOUND_MAX_X or global_position.x < Global.SCREEN_BOUND_MIN_X:
		queue_free()

func _on_area_entered(area):
	# Hit by a bullet, remove the shark and bullet
	if area.is_in_group("PlayerBulletGroup"):
		SoundManager.play_sound(DeathSound)
		Global.current_points += points_value
		GameEvent.emit_signal("update_points")
		instance_death_pieces()
		# the parent of the area is player_bullet
		area.queue_free()
		queue_free()
	# Touched the player, send the game over signal
	elif area.is_in_group("PlayerGroup"):
		area.death()
	
func flip_direction():
	velocity = -velocity
	sprite.flip_h = !sprite.flip_h

func instance_death_pieces():
	for i in range(PIECE_COUNT):
		var object_piece_instance = ObjectPiece.instantiate()
		object_piece_instance.frame = i
		object_piece_instance.global_position = global_position
		get_tree().current_scene.add_child(object_piece_instance)

func _pause(pause):
	state = State.PAUSED if pause else State.DEFAULT
