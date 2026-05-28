extends Node

class_name FarkleGame

enum GameState { InTurn, InTransition }
const MAX_DICE: int = 6

var target_score: int = 0
var players: Array[Player] = []
var active_player_index: int
var active_player: Player:
	get:
		return players[active_player_index]

var state: GameState = GameState.InTurn # TODO: Set from UI

func _init() -> void:
	for i in range(2):
		players.append(Player.new())

	active_player_index = 0

# TODO: temp, figure out better way to progress
func progress_turn():
	active_player.release_all_die()
	active_player_index = (active_player_index + 1) % players.size()
