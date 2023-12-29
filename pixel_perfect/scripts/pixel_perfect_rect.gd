class_name PixelPerfectRect extends TextureRect

# PIXEL PERFECT RECT
# Manages the texture rect object which displays the upscaled image to the screen.
# Starts by linking the viewport texture to the source texture, and recalculates margins/scale factor on every resize.

signal scale_factor_changed(new_factor)

var native_size = Vector2i(512, 288)
var scale_factor = 1
var pixel_offset = Vector2i.ZERO

func _ready():
	get_tree().get_root().connect("size_changed",Callable(self,"resize")) # Call resize on scene size change

# Update the scene when resized
func resize():
	update_rect()

# UPDATE THE RECT TEXTURE
func update_rect():
	var screen_size = get_viewport_rect().size
	size = native_size # Set size
	
	scale_factor = calc_scale_factor(screen_size) # Calculate the correct scale factor
	scale = Vector2(scale_factor, scale_factor) # SET RECT SCALE
	scale_factor_changed.emit(scale_factor) # Emit a signal on scale_factor change

	# CALCULATE MARGINS
	var x_margin = (screen_size.x - (scale_factor * native_size).x) / 2.0	# Position at center of window (difference of screen and upscaled divided by 2 since there are 2 margins)
	var y_margin = (screen_size.y - (scale_factor * native_size).y) / 2.0
	position = Vector2(x_margin + pixel_offset.x, y_margin + pixel_offset.y)

# Calculate the max possible scale factor given a screen size
func calc_scale_factor(screen_size):
	var temp_scale_factor = 1
	while (native_size * temp_scale_factor).x <= screen_size.x and (native_size * temp_scale_factor).y <= screen_size.y: # Increasing when smaller than dimensions, goes to one over
		temp_scale_factor += 1
	return temp_scale_factor - 1 # Return the size that fits within the screen

