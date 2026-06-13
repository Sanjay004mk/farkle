@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextScalePulseEffect
extends RichTextEffect

var bbcode = "scale_pulse_effect"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var freq = char_fx.env.get("freq", 2.0)
	var max_scale = char_fx.env.get("amount", 1.2)
	var offset = char_fx.env.get("offset", 0.5) 
	var seed_val = char_fx.env.get("seed", 0.0) # <-- Add the seed parameter
	
	# Add the seed_val to shift the sine wave's starting phase
	var time = (char_fx.elapsed_time * freq) + (char_fx.relative_index * offset) + seed_val
	var s = 1.0 + (sin(time) * 0.5 + 0.5) * (max_scale - 1.0)
	
	var center_offset = Vector2(8, 8) 
	char_fx.transform = char_fx.transform.translated(-center_offset).scaled(Vector2(s, s)).translated(center_offset)
	
	return true
