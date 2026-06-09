extends Die

class_name AnimatedDie

@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var dice: Node3D = $Path3D/PathFollow3D/Node3D/dice
@onready var area_3d: Area3D = $Path3D/PathFollow3D/Node3D/dice/Area3D

const _DIE_NUMBER_FACES_AND_ANGLES: Array = [
	[Vector3.FORWARD, 90],
	[Vector3.UP, 0],
	[Vector3.BACK, 90],
	[Vector3.BACK, 180],
	[Vector3.RIGHT, 90],
	[Vector3.LEFT, 90],
]

const _PER_CURVE_ROTATION_DATA: Array = [
	[4, 0, 5, 2, 1, 3]
]

var _on_die_clicked_callback: Callable
var _roll_tween: Tween
var _selection_tween: Tween

func set_on_die_clicked_callback(p_callback: Callable):
	if _on_die_clicked_callback and area_3d.input_event.is_connected(_on_die_clicked_callback):
		area_3d.input_event.disconnect(_on_die_clicked_callback)

	_on_die_clicked_callback = func(_camera, event, _position, _normal, _shape_idx):  
			if event is InputEventMouseButton and event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT and not _roll_tween.is_running(): 
				p_callback.call()

	area_3d.input_event.connect(_on_die_clicked_callback)

func _orient_die():
	var data = _DIE_NUMBER_FACES_AND_ANGLES[_PER_CURVE_ROTATION_DATA[0][number - 1]]
	dice.rotate(data[0], deg_to_rad(data[1]))

func _reset_die_transform():
	if _roll_tween:
		_roll_tween.kill()

	path_follow_3d.progress_ratio = 0.0
	dice.rotation = Vector3.ZERO

func roll(p_distribution: float) -> int:
	super(p_distribution)

	_reset_die_transform()
	_orient_die()

	_roll_tween = create_tween().set_parallel(true)
	dice.rotate(Vector3.UP, deg_to_rad(randf_range(-10, 10)))

	_roll_tween.tween_property(path_follow_3d, "progress_ratio", 1.0, 1.0 + randf() * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return _number

func toggle_select(p_selected: bool):
	if _selection_tween:
		_selection_tween.kill()

	var final_value = Vector3.UP if p_selected else Vector3.ZERO
	_selection_tween = create_tween()
	_selection_tween.tween_property(dice, "position", final_value, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	super(p_selected)
