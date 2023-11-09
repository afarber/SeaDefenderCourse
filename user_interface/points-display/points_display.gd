extends Label

func _ready():
	GameEvent.connect("update_points", Callable(self, "_points_updated"))

func _points_updated():
	text = str(Global.current_points)
