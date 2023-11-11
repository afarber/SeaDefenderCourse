extends Control

@onready var current_score_label = $CurrentScoreLabel

func _ready():
	GameEvent.connect("game_over", Callable(self, "_activate_game_over"))
	visible = false

func _activate_game_over():
	current_score_label.text = "Score " + str(Global.current_points)
	visible = true
