extends Node

class_name Die

var _number: int
var number:
	get:
		return _number

var _default_distribution: float = (1.0 / 6.0)

## Roll the die with the given real value.
## @param p_value: rand float between 0 and 1. Die number is decided based on the die's probability distribution
## Returns the rolled number
func roll(p_value: float) -> int:
	if OS.is_debug_build():
		if p_value < 0.0 or p_value > 1.0:
			printerr("Passing invalid value to roll: ", p_value)
			p_value = clamp(p_value, 0.0, 1.0)
	_number = int((p_value / _default_distribution) + 1) 
	return _number
