extends Node

class_name Dice

var _number: int = 0
var number: 
	get: 
		return _number

var locked: bool = false

func roll(value: int):
	if not locked:
		_number = value
