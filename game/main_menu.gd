extends Control

class_name MainMenu

@onready var back_button: LinkButton = $TitleAndMenu/TitleAndMainMenu/Title/BackButton

@onready var menus: Dictionary = {
	"main": $TitleAndMenu/TitleAndMainMenu/MainMenu,
	"difficulty": $TitleAndMenu/TitleAndMainMenu/DifficultyMenu,
	"rules": $TitleAndMenu/TitleAndMainMenu/RulesMenu
}
const _DIFFICULTY_OPTIONS: Array[int] = [1500, 2000, 4000, 5000, 6000, 8000]
@onready var difficulty_buttons: Array[LinkButton] = [
	$TitleAndMenu/TitleAndMainMenu/DifficultyMenu/DifficultyOptions/DifficultyOptions/Body/MarginContainer/HBoxContainer/VBoxContainer/MainMenuButton/MarginContainer/LinkButton, $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/DifficultyOptions/DifficultyOptions/Body/MarginContainer/HBoxContainer/VBoxContainer/MainMenuButton2/MarginContainer/LinkButton, $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/DifficultyOptions/DifficultyOptions/Body/MarginContainer/HBoxContainer/VBoxContainer/MainMenuButton3/MarginContainer/LinkButton, $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/DifficultyOptions/DifficultyOptions/Body/MarginContainer/HBoxContainer/VBoxContainer2/MainMenuButton4/MarginContainer/LinkButton, $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/DifficultyOptions/DifficultyOptions/Body/MarginContainer/HBoxContainer/VBoxContainer2/MainMenuButton5/MarginContainer/LinkButton, $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/DifficultyOptions/DifficultyOptions/Body/MarginContainer/HBoxContainer/VBoxContainer2/MainMenuButton6/MarginContainer/LinkButton
]

@onready var mode_buttons: Dictionary = {
	"player": {
		"enum": FarkleGameState.VsMode.VS_Player,
		"visual": $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/Mode/DifficultyOptions/Heading/MarginContainer/HBoxContainer/MainMenuButton/MarginContainer/LinkButton/DisablePanel, 
		"button": $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/Mode/DifficultyOptions/Heading/MarginContainer/HBoxContainer/MainMenuButton/MarginContainer/LinkButton, 
	},
	"computer": {
		"enum": FarkleGameState.VsMode.VS_Computer,
		"visual": $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/Mode/DifficultyOptions/Heading/MarginContainer/HBoxContainer/MainMenuButton2/MarginContainer/LinkButton/DisablePanel,
		"button": $TitleAndMenu/TitleAndMainMenu/DifficultyMenu/Mode/DifficultyOptions/Heading/MarginContainer/HBoxContainer/MainMenuButton2/MarginContainer/LinkButton
	}
}
func _ready() -> void:
	back_button.mouse_entered.connect(func(): back_button.modulate = Color.GRAY)
	back_button.mouse_exited.connect(func(): back_button.modulate = Color.WHITE)
	back_button.pressed.connect(func(): _show_menu("main"))
	back_button.hide()

	for mode in mode_buttons:
		var btn = mode_buttons[mode]
		btn.button.pressed.connect(func(val = btn.enum): 
			FarkleGameState.vs_mode = val
			_update_mode_visual_state()
		)
	_update_mode_visual_state()

	for i in range(_DIFFICULTY_OPTIONS.size()):
		var btn := difficulty_buttons[i]
		btn.pressed.connect(func(): _start_level(_DIFFICULTY_OPTIONS[i]))

	_show_menu("main")

func _update_mode_visual_state():
	for mode in mode_buttons:
		var btn = mode_buttons[mode]
		if FarkleGameState.vs_mode == btn.enum:
			btn.visual.hide()
		else:
			btn.visual.show()

func _start_level(p_difficulty: int):
	FarkleGameState.target_score = p_difficulty
	get_tree().change_scene_to_file("res://game/game.tscn")

func _show_menu(p_menu: String):
	for menu_name in menus:
		if menu_name == p_menu:
			menus[menu_name].show()
		else:
			menus[menu_name].hide()

	back_button.visible = p_menu != "main"

func on_start_pressed() -> void:
	_show_menu("difficulty")

func on_rules_pressed() -> void:
	_show_menu("rules")

func on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func on_mode_selected(p_mode: int):
	if p_mode == 0:
		FarkleGameState.vs_mode = FarkleGameState.VsMode.VS_Computer
	else:
		FarkleGameState.vs_mode = FarkleGameState.VsMode.VS_Player
