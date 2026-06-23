extends Node

const LOADING_SCREEN = preload("uid://c41hcuq0s8dqw")
var scene_path: String = "res://game/main_menu.tscn"

func load_scene(p_scene_name):
	scene_path = p_scene_name
	get_tree().change_scene_to_packed(LOADING_SCREEN)
