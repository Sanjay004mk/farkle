extends Node

class_name FarkleGame

enum GameState { InTurn, InTransition }
const MAX_DICE: int = 6

var target_score: int = 5000
var players: Array[Player] = []
var active_player_index: int
var active_player: Player:
	get:
		return players[active_player_index]

var other_player: Player:
	get:
		return players[(active_player_index + 1) % 2]

var state: GameState = GameState.InTurn # TODO: Set from UI

signal player_switched

func _init() -> void:
	for i in range(2):
		players.append(Player.new())

	active_player_index = 0

func player_roll() -> bool:
	if not FarkleRules.is_valid_selection(active_player.selected_dice):
		return false

	active_player.roll()
	return true

func _player_score() -> bool:
	if not FarkleRules.is_valid_selection(active_player.selected_dice):
		return false

	var round_score := active_player.score()
	if round_score == 0:
		return false

	return true

func progress_turn() -> bool:
	if not _player_score():
		return false

	switch_player()
	return true

func switch_player() -> void:
	active_player.release_all_die()
	active_player_index = (active_player_index + 1) % players.size()

	active_player.roll()

	player_switched.emit()
