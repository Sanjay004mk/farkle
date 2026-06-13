extends Control

class_name MainMenu

@onready var game_difficulty_selector_margin: MarginContainer = $TitleAndMainMenuMargin/HBoxContainer/GameDifficultySelectorMargin
@onready var difficulty_options: VBoxContainer = $TitleAndMainMenuMargin/HBoxContainer/GameDifficultySelectorMargin/GameDifficultySelector/VBoxContainer/DifficultyOptions

const _DIFFICULTY_OPTIONS: Array[int] = [1500, 2000, 4000, 5000, 6000, 8000]

func on_start_pressed() -> void:
	game_difficulty_selector_margin.show()
	for child in difficulty_options.get_children():
		child.queue_free()

	for option in _DIFFICULTY_OPTIONS:
		var button: Button = Button.new()
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.text = "%d Points" % option
		button.pressed.connect(func(): 
			FarkleGameState.target_score = option
			get_tree().change_scene_to_file("res://game/game_ui.tscn")
		)
		difficulty_options.add_child(button)

func on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
