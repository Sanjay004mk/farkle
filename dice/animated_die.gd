extends Die

class_name AnimatedDie

@onready var idle_mesh: MeshInstance3D = $IdleMesh

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
	[4, 0, 3, 2, 1, 5],
	[4, 0, 3, 2, 1, 5],
	[5, 2, 1, 0, 3, 4], # For IdleMesh
]

var _on_die_clicked_callback: Callable
var _audio_tween: Tween
var _selection_tween: Tween
var _reappear_tween: Tween

signal roll_animation_finished
signal reappear_animation_finished

func set_on_die_clicked_callback(p_callback: Callable):
	if _on_die_clicked_callback and dice_click_handle.input_event.is_connected(_on_die_clicked_callback):
		dice_click_handle.input_event.disconnect(_on_die_clicked_callback)

	_on_die_clicked_callback = (
	func(_camera, event, _position, _normal, _shape_idx):  
		if event is InputEventMouseButton and event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT and not _audio_tween.is_running(): 
			p_callback.call()
	)

	dice_click_handle.input_event.connect(_on_die_clicked_callback)

func _orient_die(p_animation_index: int, p_idle_mesh: bool = false):
	var data = _DIE_NUMBER_FACES_AND_ANGLES[_PER_CURVE_ROTATION_DATA[p_animation_index - 1][number - 1]]
	if p_idle_mesh:
		idle_mesh.rotation = Vector3.ZERO
		idle_mesh.rotate(data[0], deg_to_rad(data[1]))
	else:
		dice_rotation_handle.rotation = Vector3.ZERO
		dice_rotation_handle.rotate(data[0], deg_to_rad(data[1]))

func reappear_at(p_global_position: Vector3) -> void:
	if _reappear_tween:
		_reappear_tween.kill()

	idle_mesh.hide()
	var old_scale = idle_mesh.scale
	idle_mesh.scale = Vector3(1.0, 1.0, 1.0)
	idle_mesh.global_position = p_global_position
	_orient_die(7, true)
	idle_mesh.scale = old_scale
	idle_mesh.show()

	_reappear_tween = get_tree().create_tween()
	_reappear_tween.tween_property(dice_rotation_handle, "scale", Vector3.ZERO, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	_reappear_tween.tween_callback(func(): 
		dice_rotation_handle.scale = Vector3(1.0, 1.0, 1.0)
		dice_animation_player.stop() # Stop resets the position of the die
		dice_movement_handle.hide()
	)
	_reappear_tween.tween_property(idle_mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	_reappear_tween.finished.connect(func(): reappear_animation_finished.emit())

func hide_idle_mesh() -> void:
	if _reappear_tween:
		_reappear_tween.kill()

	_reappear_tween = get_tree().create_tween()
	_reappear_tween.tween_property(idle_mesh, "scale", Vector3.ZERO, 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	await _reappear_tween.finished

func _kill_all_tweens():
	if _reappear_tween:
		_reappear_tween.kill()
	if _audio_tween:
		_audio_tween.kill()
	if _selection_tween:
		_selection_tween.kill()

func animate_roll(p_start_position: Vector3) -> void:
	_kill_all_tweens()
	await hide_idle_mesh()
	dice_rotation_handle.scale = Vector3(1.0, 1.0, 1.0)
	dice_animation_player.stop() # Stop resets the position of the die
	dice_movement_handle.global_position = p_start_position
	dice_movement_handle.show()

	var animation_index: int = randi_range(1, 6)
	_orient_die(animation_index)

	_audio_tween = create_tween().set_parallel(true)

	var rand_delay := randf() * 0.5
	_audio_tween.tween_callback(func(): audio_stream_player_3d.play()).set_delay(1.0 + rand_delay)
	_audio_tween.finished.connect(func(): roll_animation_finished.emit())
	dice_animation_player.play("Roll_00" + str(animation_index), -1, 1.0 + rand_delay)

func toggle_select(p_selected: bool):
	if _selection_tween:
		_selection_tween.kill()

	var final_value = dice_movement_handle.global_position
	final_value.y = 1.5 if p_selected else 0.5
	_selection_tween = create_tween()
	_selection_tween.tween_property(dice_movement_handle, "global_position", final_value, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	super(p_selected)
