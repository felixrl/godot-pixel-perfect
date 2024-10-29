class_name PixelPerfectNode 
extends CanvasLayer

## PIXEL PERFECT NODE
## User accessible exports for resolution, palette, etc.
## Assign & process SubViewport to TextureRect logic
## Window resizing

## EXPORTS
@export_group("Required")
# Native size (editable from inspector)
@export var native_pixel_res : Vector2i = Vector2i(512, 288)
@export var src_sub_viewport : SubViewport

@export_group("Palette")
# Image reference for the palette source
@export var src_palette_texture : Texture2D 
# Total value for one property (r,g,b) (only used for texture map mode)
@export var accuracy_scale : int = 128 

@export_group("Misc")
# Color of the background behind the main render
@export var bg_colour : Color

## VARIABLES
# Texture to draw pixel to
@onready var pixel_texture : PixelPerfectRect = $TextureRect
# Palette info script
@onready var pixel_palette : PixelPerfectPalette = $Palette 
@onready var bg = $Bg
# Current runtime scale factor
@onready var scale_factor = 1 

var pixel_offset : Vector2 = Vector2i.ZERO
var screen_res : Vector2 = Vector2.ZERO
var margins : Vector2 = Vector2.ZERO



## LOGIC
# On ready, set texture rect information and call update to get accurate info
func _ready():
	PixelPerfect.pixel_perfect = self
	
	# SETUP AT START
	bg.show()
	bg.color = bg_colour
	
	pixel_texture.show()

	setup_sub_viewport()
	setup_pixel_texture()
	setup_palette()

	# RESIZE SETUP
	get_tree().get_root().connect("size_changed",Callable(self,"resize")) # Call resize on scene size change
	resize()
	
	init_window_scale()

# On window resize
func resize(): 
	# UPDATE SCREEN SIZE
	screen_res = get_viewport().size # Update size
	
	# UPDATE SCALE FACTOR and MARGINS
	scale_factor = calc_scale_factor(screen_res)
	margins = calc_margins(screen_res)
	
	# UPDATE RENDER RECT
	pixel_texture.update_rect(self)



## SETUP
func setup_sub_viewport():
	src_sub_viewport.size = native_pixel_res # Set the viewport to the pixel size (native size)
	
	src_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS # ALWAYS UPDATE RENDER
	src_sub_viewport.handle_input_locally = false # USE GLOBAL INPUT
	src_sub_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST # PIXEL NEAREST FILTER
	
	src_sub_viewport.audio_listener_enable_2d = true # ENABLE AUDIO
	src_sub_viewport.audio_listener_enable_3d = true
func setup_pixel_texture():
	pixel_texture.texture = src_sub_viewport.get_texture() # Assign viewport texture to render from
	pixel_texture.sub_viewport_node = src_sub_viewport # Set viewport for input handling
func setup_palette():
	pixel_palette.init_with_list(src_palette_texture, pixel_texture) # Initialise the palette
	# pixel_palette.init_with_lookup(src_palette_texture, pixel_texture, accuracy_scale) # Initialise the palette



## CALCULATIONS
# Calculate the max possible scale factor given a screen size
func calc_scale_factor(screen_size):
	var temp_scale_factor = 1
	while (native_pixel_res * temp_scale_factor).x <= screen_size.x and (native_pixel_res * temp_scale_factor).y <= screen_size.y: # Increasing when smaller than dimensions, goes to one over
		temp_scale_factor += 1
	return temp_scale_factor - 1 # Return the size that fits within the screen
# Calculate the margins to centre the screen
func calc_margins(screen_size):
	var x_margin = (screen_size.x - (scale_factor * native_pixel_res).x) / 2.0 # Position at center of window (difference of screen and upscaled divided by 2 since there are 2 margins)
	var y_margin = (screen_size.y - (scale_factor * native_pixel_res).y) / 2.0
	return Vector2(x_margin, y_margin)
# Calculate maximum scale factor in the screen display
func calc_max_scale_factor():
	var max_screen_size = DisplayServer.screen_get_size()
	return calc_scale_factor(max_screen_size) - 1



## WINDOW RESIZING

# NOTES
# A little bit glitchy when the fullscreen changes or the window size
# Window pivot is in the top left, not in the centre of the window

var max_window_scale = 1
var current_window_scale = 2 : set = set_current_window_scale, get = get_current_window_scale
func set_current_window_scale(new_value):
	current_window_scale = new_value

	if current_window_scale <= 0:
		current_window_scale = max_window_scale
	elif current_window_scale > max_window_scale:
		current_window_scale = 1

	set_window_scale()
func get_current_window_scale():
	return current_window_scale

func init_window_scale(): # Init max scale and apply
	max_window_scale = calc_max_scale_factor()
	set_window_scale()

# WINDOW SCALE
func set_window_scale():
	DisplayServer.window_set_size(Vector2i(native_pixel_res.x * current_window_scale, native_pixel_res.y * current_window_scale))
func increase_window_scale():
	current_window_scale += 1
	set_window_scale()
func decrease_window_scale():
	current_window_scale -= 1

# FULLSCREEN TOGGLES
func activate_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func activate_windowed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		activate_windowed()
	else:
		activate_fullscreen()

# func _process(_delta):
# 	if Input.is_action_just_pressed("increase"):
# 		increase_window_scale()
# 	elif Input.is_action_just_pressed("decrease"):
# 		toggle_fullscreen()

func _process(delta: float) -> void:
	pass
