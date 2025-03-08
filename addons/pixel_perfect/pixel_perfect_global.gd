class_name PixelPerfectGlobal
extends Node

## Singleton for relevant accessors and screen-world transformations
## Added to Autoload registry as "PixelPerfect"

# TO-DO
# Create a utility function which converts to world position using only unit convert and not transformation as well (Seperate unit and transform!)

var pixel_perfect : PixelPerfectWindow # PIXEL PERFECT NODE TO ACCESS

@onready var screen_resolution: Vector2i = get_screen_resolution()
func get_screen_resolution() -> Vector2i:
	return get_viewport().size

#region SCREEN SPACE



## MOUSE TRANSFORMATIONS

## Produces the mouse's HD SCREEN position on the screen,
## using Godot's built-in mouse position logic
func get_mouse_screen_position() -> Vector2:
	return get_viewport().get_mouse_position()

## Produces the mouse's PIXEL position on the SCREEN,
## where (0, 0) is the centre of the pixel perfect native screen
#func get_mouse_pixel_position() -> Vector2: 
	#if not is_instance_valid(pixel_perfect): # No pixel perfect yet, approximate
		#return get_mouse_screen_position() - get_viewport().size / 2.0
	#
	## Transform to world space
	#return _screen_to_world_space(get_mouse_screen_position())

## Produces the mouse's PIXEL position in the viewport's WORLD,
## where (0, 0) is the world's origin,
## and the centre of the screen is assumed to be the position of the active Camera2D
#func get_mouse_world_pixel_position() -> Vector2: 
	#if not is_instance_valid(pixel_perfect) or not is_instance_valid(pixel_perfect.source_viewport.get_camera_2d()):
		#return get_mouse_pixel_position() # Checking to make sure there IS a camera...
	#
	#return pixel_perfect.source_viewport.get_camera_2d().position + get_mouse_pixel_position()
#


## MOUSE DELTA
## TODO: Sort out and refine logic...

@onready var previous_screen_position = get_mouse_screen_position()
@onready var cursor_screen_delta = Vector2(0,0)
@onready var cursor_world_delta = Vector2(0,0)

## Produces the change in SCREEN position since the last frame
func get_screen_delta() -> Vector2:
	return cursor_screen_delta
## Produces the change in WORLD position since the last frame
func get_world_delta() -> Vector2:
	return cursor_world_delta

#func update_cursor_delta(_delta):
	#if not is_instance_valid(pixel_perfect):
		#return
	#
	## CALCULATE DELTA
	#cursor_screen_delta = get_mouse_screen_position() - previous_screen_position
	## cursor_screen_delta = Vector2(cursor_screen_delta.x * delta, cursor_screen_delta.y * delta)
	## Determine world units (make sure to set in the middle of the half)
	#cursor_world_delta = _screen_to_world_space(cursor_screen_delta + (Vector2(pixel_perfect.native_pixel_res.x, pixel_perfect.native_pixel_res.y) / 2 * pixel_perfect.scale_factor) + pixel_perfect.margins) # Is the offset to account for world conversion considering midpoint to be 0?
	## print(cursor_screen_delta)
	## Update previous
	#previous_screen_position = get_mouse_screen_position()
#


## LOGIC PROCESSING
#
#func _process(delta):
	#update_cursor_delta(delta)



## UTILITY FUNCTIONS

func screen_to_world_space(screen_position: Vector2, resizer: PixelPerfectResizer) -> Vector2:
	var relative_to_centre_position = compute_screen_position_relative_to_centre(screen_position, resizer)
	var unclamped_world_position = screen_to_unclamped_world_coordinate(relative_to_centre_position, resizer)
	var clamped_world_position = clamp_world_coordinate(unclamped_world_position, resizer)
	return clamped_world_position

## CLAMP an UNCLAMPED WORLD COORDINATE to be within the "viewport" space.
## Assumes that UNCLAMPED WORLD COORDINATE is such that (0,0) is the CENTRE of the viewport space
func clamp_world_coordinate(unclamped_world_coordinate: Vector2, resizer: PixelPerfectResizer) -> Vector2:
	var half_native_resolution = resizer.native_resolution / 2.0
	return unclamped_world_coordinate.clamp(-half_native_resolution, half_native_resolution)

## Convert a SCREEN COORDINATE to WORLD COORDINATE space, BUT NOT LIMITED TO THE VIEWPORT SIZE
func screen_to_unclamped_world_coordinate(screen_position: Vector2, resizer: PixelPerfectResizer) -> Vector2:
	return screen_position / resizer.scale_factor

## Compute a SCREEN POSITION where (0,0) is the CENTRE of the pixel subviewport...
func compute_screen_position_relative_to_centre(screen_position: Vector2, resizer: PixelPerfectResizer) -> Vector2:
	var margins = resizer.margins
	var half_of_upsized_resolution = resizer.get_upscaled_resolution() / 2.0
	var relative_to_centre_position = screen_position - margins - half_of_upsized_resolution
	return relative_to_centre_position
