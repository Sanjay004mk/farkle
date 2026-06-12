extends Control

class_name GameUI

@onready var turn_label: Label = $VBoxContainer/TurnLabel
@onready var current_score: Label = $VBoxContainer/CurrentScore
@onready var banked_score: Label = $VBoxContainer/BankedScore
@onready var target_score: Label = $VBoxContainer/TargetScore
@onready var player_score: Array[Label] = [
	$Scores/Player1Score,
	$Scores/Player2Score
]
@onready var game_over_label: Label = $GameOverLabel

@onready var game: AnimatedFarkleGame = $AspectRatioContainer/SubViewportContainer/SubViewport/game

var on_roll_pressed: Callable
var on_pass_pressed: Callable

func _ready() -> void:
	game.initialize(self)

func _on_roll():
	if on_roll_pressed:
		on_roll_pressed.call()

func _on_pass():
	if on_pass_pressed:
		on_pass_pressed.call()

func on_game_over(p_player_index: int):
	game_over_label.text = "Game Over\nPlayer %d Wins" % [p_player_index + 1]
	game_over_label.show()

func set_target_score(p_target_score: int):
	target_score.text = "Target Score: %d" % [p_target_score]

func update_active_score(p_current_score: int, p_banked_score: int):
	current_score.text = "Current Score: %d" % [p_current_score]
	banked_score.text = "Banked Score: %d" % [p_banked_score]

func update_player_turn(p_player_index: int):
	turn_label.text = "Player %d's turn" % [p_player_index + 1]

func update_player_score(p_player_index: int, p_score: int):
	player_score[p_player_index].text = "Player %d Score: %d" % [p_player_index + 1, p_score]
