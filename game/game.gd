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

signal all_dice_rolled
signal all_dice_moved

func _ready() -> void:
	for player_index in range(players.size()):
		var player = players[player_index]
		for i in range(FarkleGame.MAX_DICE):
			var die: AnimatedDie = ANIMATED_DIE.instantiate()
			add_child(die)
			die.on_selected.connect(func(_selected): game_ui.update_active_score(active_player.current_score, active_player.banked_score))
			die.position = Vector3.ZERO
			player.assign_die(die, i)
			die.set_on_die_clicked_callback(func(): if not is_computer_turn: toggle_select(player, i))

	game_over.connect(game_ui.on_game_over)
	game_ui.on_roll_pressed = func(): if not (is_computer_turn or is_game_over): player_roll()
	game_ui.on_pass_pressed = func(): if not (is_computer_turn or is_game_over): progress_turn()
	game_ui.set_target_score(FarkleGameState.target_score)
	player_switched.connect(func(): game_ui.update_player_turn(active_player_index))
	for i in range(players.size()):
		players[i].points_updated.connect(func(total): game_ui.update_player_score(i, total))

	await _move_other_player_die()
	active_player.roll()
	await play_roll_animation()
	await _check_valid_turn()

func _check_valid_turn():
	while active_player.is_farkle:
		await game_ui.on_turn_bust()
		await switch_player()

# TODO: UI animations

func player_roll() -> bool:
	var ret := super()
	if ret:
		game_ui.update_active_score(active_player.current_score, active_player.banked_score)

		if active_player.used_dice.size() > 0:
			var positions = []
			for i in range(active_player.used_dice.size()):
				positions.append(die_rest_points[active_player_index][i].global_position)
			await _move_dice_async(active_player.used_dice, positions)

		await play_roll_animation()
		await _check_valid_turn()

	return ret

func progress_turn() -> bool:
	var ret := super()
	if ret:
		await _check_valid_turn()

	return ret

func _move_dice_async(p_dice: Array, p_position: Array):
	assert(p_dice.size() == p_position.size())
	var reappear_count = {"count": 0}
	var finised_count = p_dice.size()
	for i in range(p_dice.size()):
		var die: AnimatedDie = p_dice[i]
		assert(die)
		die.reappear_at(p_position[i])
		die.reappear_animation_finished.connect(
			func(): 
				reappear_count.count += 1
				if reappear_count.count == finised_count:
					all_dice_moved.emit()
		, CONNECT_ONE_SHOT)

	await all_dice_moved

func _move_other_player_die():
	var positions = []
	var other_player_index = (active_player_index + 1) % 2
	for i in range(other_player.dice.size()):
		positions.append(die_rest_points[other_player_index][i].global_position)
	await _move_dice_async(other_player.dice, positions)

func switch_player() -> void:
	super()
	for die in other_player.dice:
		if die is AnimatedDie:
			die.toggle_select(false)

	await _move_other_player_die()
	game_ui.update_active_score(active_player.current_score, active_player.banked_score)

	if not is_game_over:
		await play_roll_animation()

		if active_player is ComputerPlayer and FarkleRules.has_valid_selection(active_player.unused_dice):
			is_computer_turn = true
			active_player.play_turn(on_computer_turn_complete)

func on_computer_turn_complete():
	is_computer_turn = false

func play_roll_animation():
	var spawn_points = die_spawn_points.duplicate()
	spawn_points.shuffle()
	var roll_count = {"count": 0}
	var finised_count = active_player.unused_dice.size()
	for i in range(active_player.unused_dice.size()):
		var die = active_player.unused_dice[i]
		var spawn_point = spawn_points[i].global_position
		spawn_point = Vector3(spawn_point.x + randf_range(-0.3, 0.3), spawn_point.y, spawn_point.z + randf_range(-0.3, 0.3))
		if die is AnimatedDie:
			die.animate_roll(spawn_point)
			die.roll_animation_finished.connect(
				func():
					roll_count.count += 1
					if roll_count.count == finised_count:
						all_dice_rolled.emit()
			, CONNECT_ONE_SHOT)

	await all_dice_rolled

func toggle_select_die(p_player: Player, p_die: Die):
	if is_game_over: return
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
