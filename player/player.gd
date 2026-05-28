extends Node

class_name Player

var dice: Array[Die] = []
var selected_dice: Array[Die] = []
var used_dice: Array[Die] = []

var total_points: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	for i in range(FarkleGame.MAX_DICE):
		dice.append(Die.new())

## Return value: 
##	-1 => selected die is locked
##	0 => die is selected
##	1 => die is unselected
func toggle_select(p_index: int) -> int:
	if used_dice.has(dice[p_index]):
		return -1

	if selected_dice.has(dice[p_index]):
		selected_dice.erase(dice[p_index])
		return 1

	selected_dice.append(dice[p_index])
	return 0

func roll() -> bool:
	if not selected_dice.is_empty():
		return false

	if used_dice.size() == FarkleGame.MAX_DICE:
		used_dice.clear()

	for die in dice:
		if not used_dice.has(die):
			die.roll(_rng.randf())

	return true

func score() -> int:
	if selected_dice.is_empty() or not FarkleRules.is_valid_selection(selected_dice):
		return 0

	var round_score = FarkleRules.score_selection(selected_dice)
	total_points += round_score
	used_dice.append_array(selected_dice)
	selected_dice.clear()
	return round_score

func release_all_die():
	selected_dice.clear()
	used_dice.clear()
