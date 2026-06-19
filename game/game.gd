extends FarkleGame

class_name AnimatedFarkleGame

@onready var die_spawn_points: Array[Node3D] = [$DieSpawnPoints/DieSpawnPoint1, $DieSpawnPoints/DieSpawnPoint2, $DieSpawnPoints/DieSpawnPoint3, $DieSpawnPoints/DieSpawnPoint4, $DieSpawnPoints/DieSpawnPoint5, $DieSpawnPoints/DieSpawnPoint6]
const ANIMATED_DIE = preload("uid://b21xwmel285do")
@onready var die_rest_points: Array = [
	[$DieRestPointsPlayer1/DieSpawnPoint1, $DieRestPointsPlayer1/DieSpawnPoint2, $DieRestPointsPlayer1/DieSpawnPoint3, $DieRestPointsPlayer1/DieSpawnPoint4, $DieRestPointsPlayer1/DieSpawnPoint5, $DieRestPointsPlayer1/DieSpawnPoint6],
	[$DieRestPointsPlayer2/DieSpawnPoint1, $DieRestPointsPlayer2/DieSpawnPoint2, $DieRestPointsPlayer2/DieSpawnPoint3, $DieRestPointsPlayer2/DieSpawnPoint4, $DieRestPointsPlayer2/DieSpawnPoint5, $DieRestPointsPlayer2/DieSpawnPoint6]
]
@onready var game_ui: GameUI = $GameUI

var is_computer_turn: bool = false

func _ready() -> void:
	for player_index in range(players.size()):
		var player = players[player_index]
		for i in range(FarkleGame.MAX_DICE):
			var spawn_point = die_rest_points[player_index][i]
			var die: AnimatedDie = ANIMATED_DIE.instantiate()
			add_child(die)
			die.on_selected.connect(func(_selected): game_ui.update_active_score(active_player.current_score, active_player.banked_score))
			die.position = spawn_point.position
			player.assign_die(die, i)
			die.set_on_die_clicked_callback(func(): if not is_computer_turn: toggle_select(player, i))

	game_over.connect(game_ui.on_game_over)
	game_ui.on_roll_pressed = func(): if not is_computer_turn: player_roll()
	game_ui.on_pass_pressed = func(): if not is_computer_turn: progress_turn()
	game_ui.set_target_score(FarkleGameState.target_score)
	player_switched.connect(func(): game_ui.update_player_turn(active_player_index))
	for i in range(players.size()):
		players[i].points_updated.connect(func(total): game_ui.update_player_score(i, total))

	_move_other_player_die()
	active_player.roll()
	play_roll_animation()
	_check_valid_turn()

func _check_valid_turn():
	while active_player.is_farkle:
		game_ui.on_turn_bust() # TODO: await / freeze progress until this UI update finishes
		switch_player()

# TODO: UI animations

func player_roll() -> bool:
	var ret := super()
	if ret:
		game_ui.update_active_score(active_player.current_score, active_player.banked_score)

		if not active_player.is_farkle:
			for i in range(active_player.used_dice.size()):
				var die: AnimatedDie = active_player.used_dice[i]
				if die:
					die.reappear_at(die_rest_points[active_player_index][i].global_position)

			play_roll_animation()

		_check_valid_turn()

	return ret

func progress_turn() -> bool:
	var ret := super()
	if ret:
		_check_valid_turn()

	return ret

func _move_other_player_die():
	var other_player_index = (active_player_index + 1) % 2
	for i in range(other_player.dice.size()):
		var die: AnimatedDie = other_player.dice[i]
		if die:
			die.reappear_at(die_rest_points[other_player_index][i].global_position)

func switch_player() -> void:
	super()
	for die in other_player.dice:
		if die is AnimatedDie:
			die.toggle_select(false)

	_move_other_player_die()
	game_ui.update_active_score(active_player.current_score, active_player.banked_score)

	if not is_game_over:
		# TODO: wait for animation in a better way
		await get_tree().create_timer(1.0).timeout
		play_roll_animation()

		if active_player is ComputerPlayer and FarkleRules.has_valid_selection(active_player.unused_dice):
			is_computer_turn = true
			active_player.play_turn(on_computer_turn_complete)

func on_computer_turn_complete():
	is_computer_turn = false

func play_roll_animation():
	for i in range(active_player.unused_dice.size()):
		var die = active_player.unused_dice[i]
		var spawn_point = die_spawn_points[i].global_position
		spawn_point = Vector3(spawn_point.x + randf_range(-0.3, 0.3), spawn_point.y, spawn_point.z + randf_range(-0.3, 0.3))
		if die is AnimatedDie:
			die.animate_roll(spawn_point)

func toggle_select_die(p_player: Player, p_die: Die):
	var ret = p_player.toggle_select_die(p_die)
	if not p_die:
		return

	if ret == 0:
		p_die.toggle_select(true)
	elif ret == 1:
		p_die.toggle_select(false)
	else:
		print("Die is locked. ", p_die, " Value: ", p_die.number)

func toggle_select(p_player: Player, p_index: int):
	var die: AnimatedDie = p_player.dice[p_index]
	toggle_select_die(p_player, die)
