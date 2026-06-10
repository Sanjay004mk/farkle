extends Node

class_name FarkleRules

static func has_valid_selection(p_dice: Array[Die]) -> bool:
	for die in p_dice:
		if die.number == 1 or die.number == 5:
			return true

	var die_count: Dictionary = {}
	for die in p_dice:
		if die_count.has(die.number):
			die_count[die.number] += 1
		else:
			die_count[die.number] = 1

	for die in die_count:
		if die_count[die] >= 3:
			return true

	return _is_continuous(die_count)

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
	var unique_count := die_count.size()
	if unique_count < 5:
		return false

	for number in die_count.keys():
		if number < 1 or number > 6:
			return false

	if unique_count == 6:
		return true

	return (not die_count.has(1)) or (not die_count.has(6))

static func _has_less_than_three(die_count: Dictionary) -> bool:
	for die in die_count:
		if not (die == 1 or die == 5) and (die_count[die] < 3):
			return true
	return false

static func score_selection(p_selection: Array[Die]) -> int:
	if p_selection.is_empty():
		return 0

	var die_count: Dictionary = {}
	for die in p_selection:
		if die_count.has(die.number):
			die_count[die.number] += 1
		else:
			die_count[die.number] = 1

	var selection_count := p_selection.size()
	var unique_count := die_count.size()
	if unique_count == 6 and selection_count == 6:
		return 1200

	if _is_continuous(die_count):
		var extra_ones: int = max(die_count[1] - 1, 0) if die_count.has(1) else 0
		var extra_fives: int = max(die_count[5] - 1, 0) if die_count.has(5) else 0
		return 500 + (extra_ones * 100) + (extra_fives * 50)

	var score := 0
	for number in die_count:
		var count: int = die_count[number]
		if count >= 3:
			var points: int = 1000 if number == 1 else 100 * number
			for i in range(3, count):
				points *= 2
			score += points
		else:
			if number == 1:
				score += 100 * count
			elif number == 5:
				score += 50 * count
			else:
				return 0

	return score
