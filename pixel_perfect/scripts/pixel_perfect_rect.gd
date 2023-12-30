class_name PixelPerfectRect extends TextureRect

# --------------------------------------------------------------------------------
# PIXEL PERFECT RECT
# Manages the texture rect object which displays the upscaled image to the screen.
# --------------------------------------------------------------------------------

func update_rect(pixel_perfect: PixelPerfectNode):
	size = pixel_perfect.native_pixel_res # Set to native resolution
	scale = Vector2(pixel_perfect.scale_factor, pixel_perfect.scale_factor) # Set scale factor
	position = pixel_perfect.margins + pixel_perfect.pixel_offset # Set position to centre with offset
