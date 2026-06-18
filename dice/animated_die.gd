extends Die

class_name AnimatedDie

@onready var dice_animation_player: AnimationPlayer = $animated_die_object/AnimationPlayer
@onready var dice_movement_handle: Node3D = $animated_die_object
@onready var dice_rotation_handle: MeshInstance3D = $animated_die_object/Cube_001/RotaterMesh
@onready var dice_click_handle: Area3D = $animated_die_object/Cube_001/RotaterMesh/Area3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

const _DIE_NUMBER_FACES_AND_ANGLES: Array = [
	[Vector3.FORWARD, 90],
	[Vector3.UP, 0],
	[Vector3.BACK, 90],
	[Vector3.BACK, 180],
	[Vector3.RIGHT, 90],
	[Vector3.LEFT, 90],
]

const _PER_CURVE_ROTATION_DATA: Array = [
	[4, 0, 3, 2, 1, 5],
	[4, 0, 3, 2, 1, 5],
	[5, 2, 1, 0, 3, 4],
	[5, 2, 1, 0, 3, 4],
	[5, 1, 0, 3, 2, 4],
	[4, 0, 3, 2, 1, 5],
]

var _on_die_clicked_callback: Callable
var _roll_tween: Tween
var _selection_tween: Tween

func set_on_die_clicked_callback(p_callback: Callable):
	if _on_die_clicked_callback and dice_click_handle.input_event.is_connected(_on_die_clicked_callback):
		dice_click_handle.input_event.disconnect(_on_die_clicked_callback)

	_on_die_clicked_callback = func(_camera, event, _position, _normal, _shape_idx):  
			if event is InputEventMouseButton and event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT and not _roll_tween.is_running(): 
				p_callback.call()

	dice_click_handle.input_event.connect(_on_die_clicked_callback)

func _orient_die(p_animation_index: int):
	dice_rotation_handle.rotation = Vector3.ZERO

	var data = _DIE_NUMBER_FACES_AND_ANGLES[_PER_CURVE_ROTATION_DATA[p_animation_index - 1][number - 1]]
	dice_rotation_handle.rotate(data[0], deg_to_rad(data[1]))

func animate_roll() -> void:
	var animation_index: int = randi_range(1, 6)
	 # TODO: Roll_005 is broken (Axis of rotation is not correct and the same face appears for multiple numbers)
	if animation_index == 5:
		animation_index += 1
	_orient_die(animation_index)

	if _roll_tween:
		_roll_tween.kill()
	_roll_tween = create_tween().set_parallel(true)

	var rand_delay := randf() * 0.5
	_roll_tween.tween_callback(func(): audio_stream_player_3d.play()).set_delay(1.0 + rand_delay)
	dice_animation_player.play("Roll_00" + str(animation_index), -1, 1.0 + rand_delay)

func toggle_select(p_selected: bool):
	if _selection_tween:
		_selection_tween.kill()

	var final_value = Vector3.UP if p_selected else Vector3.ZERO
	_selection_tween = create_tween()
	_selection_tween.tween_property(dice_movement_handle, "position", final_value, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	super(p_selected)
