extends FarkleGame

@onready var dice: Array[AnimatedDie] = [$AnimatedDie1, $AnimatedDie2, $AnimatedDie3, $AnimatedDie4, $AnimatedDie5, $AnimatedDie6]

func _ready() -> void:
	for i in range(dice.size()):
		active_player.assign_die(dice[i], i)
		dice[i].set_on_die_clicked_callback(func(): toggle_select(i))

func on_roll_pressed():
	active_player.roll()

func toggle_select(p_index: int):
	var ret = active_player.toggle_select(p_index)
	if ret == 0:
		dice[p_index].toggle_select(true)
	elif ret == 1:
		dice[p_index].toggle_select(false)
	else:
		print("Die is locked. ", dice[p_index], " Value: ", dice[p_index].number)
