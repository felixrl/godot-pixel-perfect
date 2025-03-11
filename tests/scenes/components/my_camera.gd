class_name MyCamera
extends SubpixelCamera

@export var follow_target: SmoothFollowTargetMarker

const LERP_RATE = 12.0
@onready var smooth_follower: SmoothFollower = %SmoothFollower

## Updating position is most ideal in physics process?
func _physics_process(delta: float) -> void:
	await get_tree().create_timer(0).timeout
	update_position(delta)

func update_position(delta: float) -> void:
	var target_position = MathUtil.decay(smooth_global_position, follow_target.now_global_position, LERP_RATE, delta);
	set_smooth_global_position(smooth_follower.compute_next_smooth_follow_global_position(smooth_global_position, target_position, follow_target))
