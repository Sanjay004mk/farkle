extends Die

class_name AnimatedDie

@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D
@onready var mesh_instance_3d: MeshInstance3D = $Path3D/PathFollow3D/Node3D/MeshInstance3D

func _ready() -> void:
	roll(randf())

func roll(p_distribution: float) -> int:
	var ret = super(p_distribution)
	var tween = create_tween().set_parallel(true)
	mesh_instance_3d.rotate_object_local(Vector3.UP, deg_to_rad(randf_range(-10, 10)))

	tween.tween_property(path_follow_3d, "progress_ratio", 1.0, 1.0 + randf() * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	return ret
