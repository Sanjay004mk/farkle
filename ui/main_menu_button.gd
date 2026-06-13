extends PanelContainer

class_name MainMenuButton

@onready var animated_label: AnimatedLabel = $MarginContainer/AnimatedLabel

# TODO: Animations
func _on_mouse_enter():
	animated_label.stop_animation()
	set_instance_shader_parameter("wave_pace", 1.0)
	modulate = Color.GRAY

func _on_mouse_exit():
	animated_label.play_animation()
	set_instance_shader_parameter("wave_pace", 2.0)
	modulate = Color.WHITE

func _ready():
	set_instance_shader_parameter("wave_seed", randf_range(0.0, 100.0))
	get_viewport().size_changed.connect(_update_shader_size)
	_update_shader_size()

func _update_shader_size() -> void:
	set_instance_shader_parameter("panel_size", size)
