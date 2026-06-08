extends Control


func on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://game/game.tscn")

func on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
