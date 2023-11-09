extends Camera2D

const FOLLOW_SPEED = 9
const MIN_HEIGHT = 70
const MAX_HEIGHT = 145

var target_position = global_position

func _ready():
	GameEvent.connect("camera_follow_player", Callable(self, "_follow_player"))
	
func _physics_process(delta):
	global_position.y = lerp(global_position.y, target_position.y, FOLLOW_SPEED * delta)

func _follow_player(player_y_position):
	target_position.y = clamp(player_y_position, MIN_HEIGHT, MAX_HEIGHT)
