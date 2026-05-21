extends Control

### Behvioral documentation
# Events:
#	- Roll: Should roll all unlocked in die if locked die are valid. If all are locked it, keep current score and unlock all
#	- Pass: Should only be available if currently locked in die are valid. Stores points and reset all die
#	- Choose die: if selected, unselect else add to the list of die to be used for point calculation

var rng := RandomNumberGenerator.new()
var dice := [Dice.new(), Dice.new(), Dice.new(),Dice.new(), Dice.new(), Dice.new()]
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
	roll()
	for i in range(6):
		dice_buttons[i].pressed.connect(func(): toggle_lock(i))

func roll() -> void:
	for i in range(6):
		dice[i].roll(rng.randi_range(1, 6))
		dice_buttons[i].text = str(dice[i].number)

func toggle_lock(i: int) -> void:
	if dice[i].locked:
		dice_buttons[i].focus_mode = Control.FOCUS_NONE
	else:
		pass # todo highlight
	dice[i].locked = !dice[i].locked

func bank() -> void:
	var values := []
	for die in dice:
		if die.locked:
			values.append(die.number)

	score.text += ", ".join(values) + "\n"

	free_all_die()
	roll()

func free_all_die() -> void:
	for die in dice:
		die.locked = false
