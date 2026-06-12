extends FarkleGame

class_name AnimatedFarkleGame

@onready var die_spawn_points: Array[Node3D] = [$DieSpawnPoints/DieSpawnPoint1, $DieSpawnPoints/DieSpawnPoint2, $DieSpawnPoints/DieSpawnPoint3, $DieSpawnPoints/DieSpawnPoint4, $DieSpawnPoints/DieSpawnPoint5, $DieSpawnPoints/DieSpawnPoint6]
const ANIMATED_DIE = preload("uid://b21xwmel285do")

var game_ui: GameUI

func initialize(p_game_ui: GameUI):
	game_ui = p_game_ui
	for player in players:
		for i in range(FarkleGame.MAX_DICE):
			var spawn_point = die_spawn_points[i]
			var die: AnimatedDie = ANIMATED_DIE.instantiate()
			add_child(die)
			die.on_selected.connect(func(_selected): game_ui.update_active_score(active_player.current_score, active_player.banked_score))
			die.position = spawn_point.position
			player.assign_die(die, i)
			die.set_on_die_clicked_callback(func(): toggle_select(player, i))

	game_over.connect(game_ui.on_game_over)
	game_ui.on_roll_pressed = player_roll
	game_ui.on_pass_pressed = progress_turn
	game_ui.set_target_score(FarkleGameState.target_score)
	player_switched.connect(func(): game_ui.update_player_turn(active_player_index))
	for i in range(players.size()):
		players[i].points_updated.connect(func(total): game_ui.update_player_score(i, total))

	_hide_other_player_die()
	active_player.roll()
	_check_valid_turn()

func _check_valid_turn():
	while not FarkleRules.has_valid_selection(active_player.unused_dice):
		switch_player()

# TODO: UI animations

func player_roll() -> bool:
	var ret := super()
	if ret:
		_check_valid_turn()
		game_ui.update_active_score(active_player.current_score, active_player.banked_score)

	return ret

func progress_turn() -> bool:
	var ret := super()
	if ret:
		_check_valid_turn()

	return ret

func _hide_other_player_die():
	for die in active_player.dice:
		die.show()

	for die in other_player.dice:
		die.hide()

func switch_player() -> void:
	super()
	for die in other_player.dice:
		if die is AnimatedDie:
			die.toggle_select(false)
	_hide_other_player_die()
	game_ui.update_active_score(active_player.current_score, active_player.banked_score)

func toggle_select(p_player: Player, p_index: int):
	var ret = p_player.toggle_select(p_index)
	var die: AnimatedDie = p_player.dice[p_index]
	if not die:
		return

	if ret == 0:
		die.toggle_select(true)
	elif ret == 1:
		die.toggle_select(false)
	else:
		print("Die is locked. ", die, " Value: ", die.number)
