extends Die

class_name AnimatedDie

@onready var path_follow_3d: PathFollow3D = $Path3D/PathFollow3D

func _ready() -> void:
	var tween = create_tween().set_parallel(true)

	tween.tween_property(path_follow_3d, "progress_ratio", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
