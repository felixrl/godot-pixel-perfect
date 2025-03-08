@tool
class_name PixelPerfectCropResizer
extends PixelPerfectResizer

## SIMILAR TO INTEGER RESZIER where instead of finding the fit,
## it looks for a value where the entire screen is filled with the resolution

## OVERRIDE
func compute_scale_factor(native_resolution: Vector2i) -> float:
	return compute_max_scale_factor(native_resolution, get_viewport().size)

## OVERRIDE
## Calculate the max possible scale factor given a screen size
## Scale factor goes in range (0, INF)
## Where the ideal scale factor has x >= screen.x and y >= screen.y
func compute_max_scale_factor(native_resolution: Vector2i, screen_size: Vector2i):
	var temp_scale_factor = 1
	while (native_resolution * temp_scale_factor).x < screen_size.x or (native_resolution * temp_scale_factor).y < screen_size.y: # Increasing when smaller than dimensions, goes to one over
		temp_scale_factor += 1
	# Return the size that makes the whole screen filled
	# BUT do not go below 1 (Overflow if screen is too small...)
	return max(temp_scale_factor, 1) 
