extends Die

class_name AnimatedDie

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var dice: MeshInstance3D = $die_animated/Cube_029/RotaterMesh
@onready var area_3d: Area3D = $die_animated/Cube_029/RotaterMesh/Area3D
@onready var animation_player: AnimationPlayer = $die_animated/AnimationPlayer

const _DIE_NUMBER_FACES_AND_ANGLES: Array = [
	[Vector3.FORWARD, 90],
	[Vector3.UP, 0],
	[Vector3.BACK, 90],
	[Vector3.BACK, 180],
	[Vector3.RIGHT, 90],
	[Vector3.LEFT, 90],
]

const _PER_CURVE_ROTATION_DATA: Array = [
	#[4, 0, 5, 2, 1, 3],
	[5, 2, 4, 0, 3, 1]
]

var _on_die_clicked_callback: Callable
var _roll_tween: Tween
var _selection_tween: Tween

func set_on_die_clicked_callback(p_callback: Callable):
	if _on_die_clicked_callback and area_3d.input_event.is_connected(_on_die_clicked_callback):
		area_3d.input_event.disconnect(_on_die_clicked_callback)

	_on_die_clicked_callback = func(_camera, event, _position, _normal, _shape_idx):  
			if event is InputEventMouseButton and event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT and not animation_player.is_playing(): 
				p_callback.call()

	area_3d.input_event.connect(_on_die_clicked_callback)

func _orient_die():
	var data = _DIE_NUMBER_FACES_AND_ANGLES[_PER_CURVE_ROTATION_DATA[0][number - 1]]
	dice.rotate(data[0], deg_to_rad(data[1]))

func animate_roll() -> void:
	_orient_die()

	_roll_tween = create_tween().set_parallel(true)
	var rand_delay := randf() * 0.5
	animation_player.play("RollAnimation", -1, 1.0 + rand_delay)
	_roll_tween.tween_callback(func(): audio_stream_player_3d.play()).set_delay(0.5 + rand_delay)

func toggle_select(p_selected: bool):
	if _selection_tween:
		_selection_tween.kill()

	var final_value = dice.global_position + Vector3.UP if p_selected else dice.global_position + Vector3.DOWN
	_selection_tween = create_tween()
	_selection_tween.tween_property(dice, "global_position", final_value, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	super(p_selected)
