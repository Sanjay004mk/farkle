extends RichTextLabel

class_name AnimatedLabel

var _plain_text_regex = RegEx.new()

const _BEGIN_TAG: String = "[wave_effect amp=1.2 freq=3.0 seed=%f][scale_pulse_effect freq=3.0 amount=1.01 seed=%f]"
const _END_TAG: String = "[/scale_pulse_effect][/wave_effect]"

func set_animated_text(p_text: String):
	text = (_BEGIN_TAG % [randf_range(0, 100.0), randf_range(0, 100.0)]) + p_text + _END_TAG

func get_plain_text():
	return _plain_text_regex.sub(text, "", true)

func stop_animation():
	text = get_plain_text()

func play_animation():
	set_animated_text(get_plain_text())

func _ready() -> void:
	_plain_text_regex.compile("\\[.*?\\]")
	set_animated_text(text)
