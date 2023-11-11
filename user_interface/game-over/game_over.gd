extends Control

@onready var current_score_label = $CurrentScoreLabel
@onready var high_score_label = $HighScoreLabel
@onready var game_over_delay_timer = $GameOverDelay

func _ready():
	GameEvent.connect("game_over", Callable(self, "_activate_game_over"))
	visible = false

func _process(delta):
	if visible and Input.is_action_just_pressed("shoot"):
		Global.current_points = 0
		Global.saved_people_count = 0
		Global.oxygen_level = 100

		get_tree().reload_current_scene()

func _activate_game_over():
	if Global.current_points > Global.high_score:
		Global.high_score = Global.current_points

	current_score_label.text = "Score " + str(Global.current_points)
	high_score_label.text = "Highscore " + str(Global.high_score)

	game_over_delay_timer.start()

func _on_game_over_delay_timeout():
	visible = true
