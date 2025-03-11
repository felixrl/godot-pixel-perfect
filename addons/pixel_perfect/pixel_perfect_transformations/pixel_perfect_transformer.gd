@tool
class_name PixelPerfectTransformer
extends Node

## Component that handles coordinate transformations between the 
## screen and a specific PixelPerfectWindow

@export var window: PixelPerfectWindow

## SCREEN to RELATIVE WORLD POSITION (Local to either (0,0) or whatever camera) which DOESN'T STOP AT THE BORDER
func screen_to_unclamped_relative_world(screen_position: Vector2) -> Vector2:
	var relative_to_centre_position = _compute_screen_position_relative_to_centre(screen_position)
	var unclamped_world_position = _screen_to_unclamped_world_coordinate(relative_to_centre_position)
	return unclamped_world_position

## SCREEN to RELATIVE WORLD POSITION (Local to either (0,0) or whatever camera)
func screen_to_relative_world(screen_position: Vector2) -> Vector2:
	return _clamp_world_coordinate(screen_to_unclamped_relative_world(screen_position))

## SCREEN to ABSOLUTE WORLD POSITION (Global world position) which DOESN'T STOP AT THE BORDER
func screen_to_unclamped_absolute_world(screen_position: Vector2) -> Vector2:
	var relative_world_position = screen_to_unclamped_relative_world(screen_position)
	if window.viewport_handler.has_camera_2d():
		var camera = window.viewport_handler.get_viewport_camera_2d()
		return camera.global_position + relative_world_position
	print("WARNING! Screen to absolute world position returning relative position due to lack of active camera.")
	return relative_world_position

## SCREEN to ABSOLUTE WORLD POSITION (Global world position)
func screen_to_absolute_world(screen_position: Vector2) -> Vector2:
	var relative_world_position = screen_to_relative_world(screen_position)
	if window.viewport_handler.has_camera_2d():
		var camera = window.viewport_handler.get_viewport_camera_2d()
		return camera.global_position + relative_world_position
	print("WARNING! Screen to absolute world position returning relative position due to lack of active camera.")
	return relative_world_position

## RELATIVE WORLD POSITION (Local to camera) to SCREEN POSITION
func relative_world_to_screen(world_position: Vector2) -> Vector2:
	var screen_position = _unclamped_world_coordinate_to_screen(world_position)
	var relative_to_top_left_corner_position = _compute_screen_position_relative_to_top_left(screen_position)
	return relative_to_top_left_corner_position

## ABSOLUTE WORLD POSITION (Global) to SCREEN POSITION 
func absolute_world_to_screen(world_position: Vector2) -> Vector2:
	if window.viewport_handler.has_camera_2d():
		var camera = window.viewport_handler.get_viewport_camera_2d()
		return relative_world_to_screen(world_position - camera.global_position)
	print("WARNING! Absolute world to screen position using relative position due to lack of active camera.")
	return relative_world_to_screen(world_position)

## CLAMP an UNCLAMPED WORLD COORDINATE to be within the "viewport" space.
## Assumes that UNCLAMPED WORLD COORDINATE is such that (0,0) is the CENTRE of the viewport space
func _clamp_world_coordinate(unclamped_world_coordinate: Vector2) -> Vector2:
	var half_native_resolution = window.native_resolution / 2.0
	return unclamped_world_coordinate.clamp(-half_native_resolution, half_native_resolution)

## Convert a SCREEN COORDINATE to WORLD COORDINATE space, BUT NOT LIMITED TO THE VIEWPORT SIZE
func _screen_to_unclamped_world_coordinate(screen_position: Vector2) -> Vector2:
	return screen_position / window.get_scale_factor()

## Convert a WORLD COORDINATE to SCREEN COORDINATE
func _unclamped_world_coordinate_to_screen(world_position: Vector2) -> Vector2:
	return world_position * window.get_scale_factor()

## Compute a SCREEN POSITION where (0,0) is the CENTRE of the pixel subviewport...
func _compute_screen_position_relative_to_centre(screen_position: Vector2) -> Vector2:
	var margins = window.get_margins()
	var half_of_upsized_resolution = window.get_upscaled_resolution() / 2.0
	var relative_to_centre_position = screen_position - margins - half_of_upsized_resolution
	return relative_to_centre_position

func _compute_screen_position_relative_to_top_left(screen_position: Vector2) -> Vector2:
	var margins = window.get_margins()
	var half_of_upsized_resolution = window.get_upscaled_resolution() / 2.0
	var relative_to_top_left_position = screen_position + margins + half_of_upsized_resolution
	return relative_to_top_left_position
