class_name MyCamera
extends SubpixelCamera

const LERP_RATE = 10.0
var target_position: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		target_position = Vector2(RandomNumberGenerator.new().randf_range(-32, 32), RandomNumberGenerator.new().randf_range(-32, 32))
	
	smooth_global_position = smooth_global_position.lerp(target_position, delta * 10.0)
