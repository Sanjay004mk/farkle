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
@onready var score: Label = $VBoxContainer/Dice/ScoreContainer/Score

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
	score.text += str(game.active_player.score()) + "\n"
	roll()
