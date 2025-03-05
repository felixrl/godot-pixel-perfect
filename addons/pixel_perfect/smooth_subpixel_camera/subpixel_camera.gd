class_name SubpixelCamera
extends Camera2D

## Camera with the behaviour to move smoothly 
## but computes the difference to offset a pixel perfect viewport so
## that it appears smooth

const SMOOTH_RATE = 10.0

@onready var current_smooth_position: Vector2 = global_position
var target_position: Vector2 = Vector2.ZERO

var subpixel_offset: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	current_smooth_position = current_smooth_position.lerp(target_position, delta * SMOOTH_RATE)
	
	global_position = round(current_smooth_position)
	
	if Input.is_action_just_pressed("ui_accept"):
		target_position = Vector2(RandomNumberGenerator.new().randf_range(-32, 32), RandomNumberGenerator.new().randf_range(-32, 32))
	
	update_subpixel_offset()

func update_subpixel_offset():
	subpixel_offset = current_smooth_position - round(current_smooth_position)
