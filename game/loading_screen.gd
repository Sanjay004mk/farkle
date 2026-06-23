extends Control

@onready var progress_bar: ProgressBar = $TitleAndLoader/TitleAndMainMenu/ProgressBar
@onready var progress_label: Label = $TitleAndLoader/TitleAndMainMenu/Progress

var progress_array: Array
var progress_value: float = 0.0

var scene_path: String

func _ready() -> void:
	scene_path = Loader.scene_path
	ResourceLoader.load_threaded_request(scene_path)

func _process(delta: float) -> void:
	var result := ResourceLoader.load_threaded_get_status(scene_path, progress_array)

	if progress_bar.value >= 1.0 and result == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(scene_path)
		)

	if progress_array[0] > progress_value:
		progress_value = progress_array[0]

	if progress_bar.value < progress_value:
		progress_bar.value = lerp(progress_bar.value, progress_value, delta)

	progress_bar.value += 0.2 * delta + (5.0 if progress_value >= 1.0 else clamp(0.9 - progress_bar.value, 0.0, 1.0))

	progress_label.text = str(int(progress_bar.value * 100.0)) + "%"
