extends Camera3D

class_name TargetedCamera

@export var target_object: MeshInstance3D
@export var fit_margin := 1.15
@export var base_fov := 70.0

func _ready():
	get_viewport().size_changed.connect(_on_window_resized)
	fov = base_fov
	_frame_target()

func _on_window_resized():
	_frame_target()

func _frame_target():
	if target_object == null or target_object.mesh == null:
		return

	var bounds := target_object.get_aabb()
	var center := bounds.get_center()
	var radius := bounds.size.length() * 0.5 * fit_margin
	var vertical_fov := deg_to_rad(fov)
	var viewport_size := get_viewport().get_visible_rect().size
	var aspect_ratio := viewport_size.x / viewport_size.y
	var horizontal_fov := 2.0 * atan(tan(vertical_fov * 0.5) * aspect_ratio)
	var fit_angle = min(vertical_fov, horizontal_fov)
	var distance := radius / sin(fit_angle * 0.5)
	var forward := -global_transform.basis.z.normalized()
	var up := Vector3.LEFT # LEFT so that the die come from the bottom (Other options FORWARD, BACK, RIGHT)

	# TODO: Remove 5 when the base has been swapped with a non-scaled mesh
	global_position = center + forward * distance * -4
	look_at(center, up)
