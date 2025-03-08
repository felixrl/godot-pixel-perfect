@tool
class_name PixelPerfectIntegerResizer
extends PixelPerfectResizer

## IMPLEMENTATION of RESIZER which only upscales by INTEGER values
## and which NEVER runs off of the screen

## OVERRIDE
func compute_scale_factor(native_resolution: Vector2i) -> float:
	return compute_max_scale_factor(native_resolution, get_viewport().size)

## Calculate the max possible scale factor given a screen size
## Scale factor goes in range (0, INF)
func compute_max_scale_factor(native_resolution: Vector2i, screen_size: Vector2i) -> int:
	var temp_scale_factor = 1
	while (native_resolution * temp_scale_factor).x <= screen_size.x and (native_resolution * temp_scale_factor).y <= screen_size.y: # Increasing when smaller than dimensions, goes to one over
		temp_scale_factor += 1
	# Return the size that fits within the screen
	# BUT do not go below 1 (Overflow if screen is too small...)
	return max(temp_scale_factor - 1, 1) 
