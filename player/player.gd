extends Node

class_name Player

var dice: Array[Die] = []
var selected_dice: Array[Die] = []
var used_dice: Array[Die] = []
var unused_dice: Array[Die]:
	get:
		return dice.filter(func(die): return not used_dice.has(die))

var round_points: Array[int] = []
var total_points: int = 0

var current_score: int:
	get:
		return FarkleRules.score_selection(selected_dice)

var banked_score: int:
	get:
		var ret: int = 0
		for points in round_points:
			ret += points
		return ret

signal points_updated(total_points)

func _init() -> void:
	for i in range(FarkleGame.MAX_DICE):
		dice.append(Die.new())

func assign_die(p_die: Die, p_index: int):
	if p_die and (p_index >= 0 and p_index < 6):
		dice[p_index] = p_die
	else:
		printerr("Invalid Die or index. Unable to assign die to player.")

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
	var round_score = FarkleRules.score_selection(selected_dice)

	round_points.append(round_score)
	used_dice.append_array(selected_dice)
	selected_dice.clear()

	if (used_dice.size() + selected_dice.size()) == FarkleGame.MAX_DICE:
		for die in used_dice:
			die.toggle_select(false)

		used_dice.clear()

	for die in dice:
		if not (used_dice.has(die) or selected_dice.has(die)):
			die.roll(randf())


	return true

func score() -> int:
	if round_points.is_empty() and (selected_dice.is_empty() or not FarkleRules.is_valid_selection(selected_dice)):
		return 0

	var round_score = FarkleRules.score_selection(selected_dice)
	round_points.append(round_score)
	for points in round_points:
		total_points += points

	round_points.clear()
	used_dice.clear()
	selected_dice.clear()

	points_updated.emit(total_points)

	return round_score

func release_all_die():
	selected_dice.clear()
	used_dice.clear()
	round_points.clear()
