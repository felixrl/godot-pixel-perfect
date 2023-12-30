extends Node

# -----------------------------------------------
# PIXEL PERFECT
# CURSOR - AUTOLOAD
# Set this to autoload! As singleton!
# Manages cursor utilities and accurate position.
# -----------------------------------------------

# TO-DO
# Create a utility function which converts to world position using only unit convert and not transformation as well (Seperate unit and transform!)

var pixel_perfect : PixelPerfectNode # PIXEL PERFECT NODE TO ACCESS



# GETTERS
func get_cursor_screen_position(): # Screen position
	return get_viewport().get_mouse_position()

func get_cursor_world_position(): # World pixel position
	if pixel_perfect != null:
		return screen_to_world_space(get_cursor_screen_position())
	else:
		return get_cursor_screen_position() - get_viewport().size / 2.0
func get_cursor_world_position_relative_to(position : Vector2): # Relative world position, for when a camera or other offset is in play (POSITION IS A VECTOR)
	return position + get_cursor_world_position()

func get_screen_delta(): # Get change since last frame on screen position
	return cursor_screen_delta
func get_world_delta() -> Vector2i: # Change since last frame on world pixel positon
	return cursor_world_delta

# UTILITY FUNCTIONS
# Convert a screen coordinate to a world space pixel coordinate (ADD MORE COMMENTS)
func screen_to_world_space(screen_position):
	var new_position = screen_position - pixel_perfect.margins - Vector2(pixel_perfect.native_pixel_res.x, pixel_perfect.native_pixel_res.y) / 2 * pixel_perfect.scale_factor
	var world_position = Vector2(clamp(new_position.x / pixel_perfect.scale_factor, -pixel_perfect.native_pixel_res.x / 2.0, pixel_perfect.native_pixel_res.x / 2.0), 
			clamp(new_position.y / pixel_perfect.scale_factor, -pixel_perfect.native_pixel_res.y / 2.0, pixel_perfect.native_pixel_res.y / 2.0))
	return world_position

# CURSOR DELTA
@onready var previous_screen_position = get_cursor_screen_position()
@onready var cursor_screen_delta = Vector2(0,0)
@onready var cursor_world_delta = Vector2(0,0)

func update_cursor_delta(_delta):
	# CALCULATE DELTA
	cursor_screen_delta = get_cursor_screen_position() - previous_screen_position
	# cursor_screen_delta = Vector2(cursor_screen_delta.x * delta, cursor_screen_delta.y * delta)
	# Determine world units (make sure to set in the middle of the half)
	cursor_world_delta = screen_to_world_space(cursor_screen_delta + (Vector2(pixel_perfect.native_pixel_res.x, pixel_perfect.native_pixel_res.y) / 2 * pixel_perfect.scale_factor) + pixel_perfect.margins) # Is the offset to account for world conversion considering midpoint to be 0?
	# print(cursor_screen_delta)
	# Update previous
	previous_screen_position = get_cursor_screen_position()

func _process(delta):
	if pixel_perfect != null:
		update_cursor_delta(delta)
