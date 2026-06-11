extends FarkleGame

@onready var turn_label: Label = $Control/VBoxContainer/TurnLabel
@onready var current_score: Label = $Control/VBoxContainer/CurrentScore
@onready var banked_score: Label = $Control/VBoxContainer/BankedScore
@onready var player_1_score: Label = $Control/VBoxContainer/Player1Score
@onready var player_2_score: Label = $Control/VBoxContainer/Player2Score
@onready var die_spawn_points: Array[Node3D] = [$DieSpawnPoints/DieSpawnPoint1, $DieSpawnPoints/DieSpawnPoint2, $DieSpawnPoints/DieSpawnPoint3, $DieSpawnPoints/DieSpawnPoint4, $DieSpawnPoints/DieSpawnPoint5, $DieSpawnPoints/DieSpawnPoint6]
@onready var game_over_label: Label = $Control/GameOverLabel
const ANIMATED_DIE = preload("uid://b21xwmel285do")

func _ready() -> void:
	for player in players:
		for i in range(FarkleGame.MAX_DICE):
			var spawn_point = die_spawn_points[i]
			var die: AnimatedDie = ANIMATED_DIE.instantiate()
			add_child(die)
			die.on_selected.connect(func(_selected): update_score())
			die.position = spawn_point.position
			player.assign_die(die, i)
			die.set_on_die_clicked_callback(func(): toggle_select(player, i))

	game_over.connect(_on_game_over)
	player_switched.connect(func(): turn_label.text = "Player %d's turn" % [active_player_index + 1])
	players[0].points_updated.connect(func(total): player_1_score.text = "Player 1's Score: %d" % [total])
	players[1].points_updated.connect(func(total): player_2_score.text = "Player 2's Score: %d" % [total])

	_hide_other_player_die()
	active_player.roll()
	_check_valid_turn()

func _on_game_over(p_player_index: int):
	game_over_label.text = "Game Over\nPlayer %d Wins" % [p_player_index + 1]
	game_over_label.show()

func _check_valid_turn():
	while not FarkleRules.has_valid_selection(active_player.unused_dice):
		switch_player()

# TODO: UI animations

func player_roll() -> bool:
	var ret := super()
	if ret:
		_check_valid_turn()
		update_score()

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
	update_score()

func update_score():
	current_score.text = "Current Score: %d" % [active_player.current_score]
	banked_score.text = "Banked Score: %d" % [active_player.banked_score]

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
