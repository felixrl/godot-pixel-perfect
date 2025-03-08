@tool
class_name PixelPerfectCenterer
extends PixelPerfectAligner

## ALIGNER for CALCULATING THE SCREEN OFFSET needed to CENTER a WINDOW

## OVERRIDE THIS!!!
func compute_margins(resolution: Vector2i) -> Vector2:
	return compute_centering_margins(resolution)

## Calculate the margins needed to centre on the screen
func compute_centering_margins(resolution: Vector2i) -> Vector2:
	var screen_resolution = get_viewport().size
	# Position at center of window (difference of screen and upscaled divided by 2 since there are 2 margins)
	var x_margin = (screen_resolution.x - resolution.x) / 2.0
	var y_margin = (screen_resolution.y - resolution.y) / 2.0
	return Vector2(x_margin, y_margin)
