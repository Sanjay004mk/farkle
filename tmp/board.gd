extends Control

var game: FarkleGame = FarkleGame.new()
@onready var dice_buttons: Array[Button] = [
	$VBoxContainer/Dice/Button1,
	$VBoxContainer/Dice/Button2,
	$VBoxContainer/Dice/Button3,
	$VBoxContainer/Dice/Button4,
	$VBoxContainer/Dice/Button5,
	$VBoxContainer/Dice/Button6
]

@onready var scores: Array[Label] = [
	$VBoxContainer/Dice/ScoreContainer/PlayerScores/Score1,
	$VBoxContainer/Dice/ScoreContainer/PlayerScores/Score2
]

func _ready() -> void:
	for i in range(6):
		dice_buttons[i].pressed.connect(func(): toggle_select(i))

func roll() -> void:
	game.active_player.roll()
	for i in range(FarkleGame.MAX_DICE):
		dice_buttons[i].text = str(game.active_player.dice[i].number)

func toggle_select(i: int) -> void:
	game.active_player.toggle_select(i)

func bank() -> void:
	var score_value = game.active_player.score()
	if score_value == 0:
		return

	scores[game.active_player_index].text += str(score_value) + "\n"
	game.progress_turn()
	roll()
