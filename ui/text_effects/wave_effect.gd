@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextWaveEffect
extends RichTextEffect

var bbcode = "wave_effect"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq = char_fx.env.get("freq", 2.0)
	var amp = char_fx.env.get("amp", 20.0)
	var offset = char_fx.env.get("offset", 0.5)
	var seed_val = char_fx.env.get("seed", 0.0)

	var time = (char_fx.elapsed_time * freq) + (char_fx.relative_index * offset) + seed_val

	var y_offset = sin(time) * amp

	char_fx.transform = char_fx.transform.translated(Vector2(0, y_offset))

	return true
