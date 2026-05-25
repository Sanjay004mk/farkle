extends Node

class_name FarkleRules

static func is_valid_selection(p_selection: Array[Die]) -> bool:
	if p_selection.is_empty():
		return false

	var die_count: Dictionary = {}
	for die in p_selection:
		if die_count.has(die.number):
			die_count[die.number] += 1
		else:
			die_count[die.number] = 1

	if _is_continuous(die_count):
		return true

	if _has_less_than_three(die_count):
		return false

	return true

static func _is_continuous(die_count: Dictionary) -> bool:
	if not (die_count.size() >= 5):
		return false
	var numbers_to_erase = [1, 2, 3, 4, 5, 6]
	for die in die_count:
		numbers_to_erase.erase(die)

	return (numbers_to_erase.size() == 0) or (numbers_to_erase.size() == 1 and (numbers_to_erase[0] == 1 or numbers_to_erase[0] == 6))

static func _has_less_than_three(die_count: Dictionary) -> bool:
	for die in die_count:
		if not (die == 1 or die == 5) and (die_count[die] < 3):
			return true
	return false

static func score_selection(p_selection: Array[Die]) -> int:
	return 0
