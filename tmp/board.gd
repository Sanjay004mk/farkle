extends Control

var rng := RandomNumberGenerator.new()
var dice := [1, 1, 1, 1, 1, 1]
@onready var dice_buttons: Array[Button] = [
	$VBoxContainer/Dice/Button1,
	$VBoxContainer/Dice/Button2,
	$VBoxContainer/Dice/Button3,
	$VBoxContainer/Dice/Button4,
	$VBoxContainer/Dice/Button5,
	$VBoxContainer/Dice/Button6
]

func _ready() -> void:
	roll()

func roll() -> void:
	for i in range(6):
		dice[i] = rng.randi_range(1, 6)
		dice_buttons[i].text = str(dice[i])
