extends Node

class_name FarkleGame

enum GameState { InTurn, InTransition }
const MAX_DICE: int = 6

var target_score: int = 0
var players: Array[Player] = []
var active_player: Player
var state: GameState = GameState.InTurn # TODO: Set from UI

func _init() -> void:
	for i in range(2):
		players.append(Player.new())

	active_player = players[0]
