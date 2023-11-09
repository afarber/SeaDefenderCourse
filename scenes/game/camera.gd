extends Camera2D

func _ready():
	GameEvent.connect("camera_follow_player", Callable(self, "_follow_player"))

func _follow_player(player_y_position):
	global_position.y = player_y_position
