extends Control

class_name GameUI

const _PLAYER_ONE_COLOR: Color = Color("FF5C77")
const _PLAYER_TWO_COLOR: Color = Color("00E5FF")

const PLAYER_COLORS: = [
	_PLAYER_ONE_COLOR,
	_PLAYER_TWO_COLOR
]

@onready var target_score: Label = $Scores/VBoxContainer/TargetScore
@onready var current_score: Label = $Scores/VBoxContainer/HBoxContainer/TurnScoreHolder/VBoxContainer/CurrentScore
@onready var banked_score: Label = $Scores/VBoxContainer/HBoxContainer/TurnScoreHolder/VBoxContainer/BankedScore
@onready var turn_label: Label = $Scores/VBoxContainer/TurnLabel


@onready var player_score: Array[Label] = [
	$Scores/VBoxContainer/HBoxContainer/Player1ScoreHolder/Score,
	$Scores/VBoxContainer/HBoxContainer/Player1ScoreHolder2/Score
]

@onready var game_over_popup: MarginContainer = $GameOverPopup
@onready var game_over_label: Label = $GameOverPopup/Popup/Body/MarginContainer/VBoxContainer/Label

@onready var pause_menu_panel: Panel = $PauseMenuPanel

@onready var bust_label: Label = $BustLabel

var on_roll_pressed: Callable
var on_pass_pressed: Callable

func _on_roll():
	if on_roll_pressed:
		on_roll_pressed.call()

func _on_pass():
	if on_pass_pressed:
		on_pass_pressed.call()

func on_turn_bust():
	bust_label.show()
	var timeout := get_tree().create_timer(1.5).timeout
	timeout.connect(func(): bust_label.hide())
	await timeout

func on_game_over(p_player_index: int):
	game_over_label.text = "Player %d Wins" % [p_player_index + 1]
	game_over_popup.show()

func _on_pause_pressed():
	pause_menu_panel.show()
	get_tree().paused = true

func _on_resume_pressed():
	pause_menu_panel.hide()
	get_tree().paused = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/game.tscn")

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://game/main_menu.tscn")

func _on_exit_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func set_target_score(p_target_score: int):
	target_score.text = "Target Score: %d" % [p_target_score]

func update_active_score(p_current_score: int, p_banked_score: int):
	current_score.text = str(p_current_score)
	banked_score.text = str(p_banked_score)

# TODO: Animations
func update_player_turn(p_player_index: int):
	turn_label.add_theme_color_override("font_color", PLAYER_COLORS[p_player_index])
	current_score.add_theme_color_override("font_color", PLAYER_COLORS[p_player_index])
	banked_score.add_theme_color_override("font_color", PLAYER_COLORS[p_player_index])

	turn_label.text = "Player %d's turn" % [p_player_index + 1]

func update_player_score(p_player_index: int, p_score: int):
	player_score[p_player_index].text = str(p_score)
