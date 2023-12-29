extends Node

# CURSOR - AUTOLOAD
# Set this to autoload! As singleton!
# Manages cursor utilities and accurate position

# TO-DO
# Create a utility function which converts to world position using only unit convert and not transformation as well (Seperate unit and transform!)

@onready var window_size := get_window().size					# Size of the game window
@onready var native_size = Vector2i(512, 288)					# Pixel resolution of the game
@onready var scale_factor = 1

var margins = Vector2.ZERO
var half_native_size = Vector2.ZERO

# GETTERS
func get_cursor_screen_position(): # Screen position
	return get_viewport().get_mouse_position()
	
func get_cursor_world_position(): # World pixel position
	return screen_to_world_space(get_cursor_screen_position())
func get_cursor_world_position_relative_to(position : Vector2): # Relative world position, for when a camera or other offset is in play (POSITION IS A VECTOR)
	return position + get_cursor_world_position()
	
func get_screen_delta(): # Get change since last frame on screen position
	return cursor_screen_delta
func get_world_delta() -> Vector2i: # Change since last frame on world pixel positon
	return cursor_world_delta

# UTILITY FUNCTIONS
# Convert a screen coordinate to a world space pixel coordinate (ADD MORE COMMENTS)
func screen_to_world_space(screen_position):
	var new_position = screen_position - margins - half_native_size * scale_factor
	var world_position = Vector2(clamp(new_position.x / scale_factor, -half_native_size.x, half_native_size.x), 
			clamp(new_position.y / scale_factor, -half_native_size.y, half_native_size.y))
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
	cursor_world_delta = screen_to_world_space(cursor_screen_delta + (half_native_size * scale_factor) + margins) # Is the offset to account for world conversion considering midpoint to be 0?
	# print(cursor_screen_delta)
	# Update previous
	previous_screen_position = get_cursor_screen_position()

# READY
func _ready():
	get_tree().get_root().connect("size_changed",Callable(self,"resize")) # On resize - CONNECT TO MAIN PIXEL PERFECT WITH EVENT SIGNAL SOMETIME
	resize()

# Calculating values
func resize():
	calculate_margins()
	calculate_half_native_size()

func calculate_margins():
	margins = (window_size - native_size * scale_factor) / 2.0
func calculate_half_native_size():
	half_native_size = native_size / 2.0
func update_window_size():
	window_size = get_window().size

func _process(delta):
	if PixelPerfect.instance != null: # temp fix for null issue, fix order of operations sometime
		scale_factor = PixelPerfect.instance.scale_factor
		resize()
	else:
		scale_factor = 1
		
	if PixelPerfect.instance != null: # temp fix for null issue, fix order of operations sometime
		if native_size != PixelPerfect.instance.pixel_size: # DIFFERENT
			native_size = PixelPerfect.instance.pixel_size # Get from pixel perfect
			resize()
	else:
		native_size = Vector2i(512, 288)

	update_window_size()
	calculate_margins()
	update_cursor_delta(delta)
