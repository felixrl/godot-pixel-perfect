class_name SubpixelCamera
extends Camera2D

## Camera with the behaviour to move smoothly 
## but computes the difference to offset a pixel perfect viewport so
## that it appears smooth

@onready var smooth_global_position: Vector2 = global_position : set = set_smooth_global_position
func set_smooth_global_position(new_global_position: Vector2) -> void:
	if not smooth_global_position.is_equal_approx(new_global_position):
		smooth_global_position = new_global_position
		smooth_position = to_local(new_global_position)
	update_global_position_as_rounded_global_position()

@onready var smooth_position: Vector2 = position : set = set_smooth_position
func set_smooth_position(new_local_position: Vector2) -> void:
	if not smooth_position.is_equal_approx(new_local_position):
		smooth_position = new_local_position
		smooth_global_position = to_global(new_local_position)
	update_global_position_as_rounded_global_position()

var subpixel_offset: Vector2 = Vector2.ZERO

## GET ROUNDED VALUES
func get_rounded_position() -> Vector2:
	return round(smooth_position)
func get_rounded_global_position() -> Vector2:
	return round(smooth_global_position)

func update_global_position_as_rounded_global_position():
	global_position = get_rounded_global_position()
	update_subpixel_offset()

func update_subpixel_offset():
	subpixel_offset = get_rounded_global_position() - smooth_global_position
