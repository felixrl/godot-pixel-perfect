class_name PixelPerfectPalette extends Node

# PIXEL PERFECT PALETTE
# Pass in an image containing the colour palette. Processes the colour palette into a list of colours and passes it to the shader.

@export var palette_image : Texture2D # Image reference to create palette
@export var target_texture : PixelPerfectRect # Texture rect to render to

@export var accuracy_scale : int = 256 # Total value for one property

var colour_palette
var lookup_texture

# On start, generate the palette and assign it to the target texture
func _ready():
	pass

func init():
	colour_palette = generate_palette(palette_image)
	# assign_list_to_target_texture(colour_palette)
	lookup_texture = generate_lookup_texture(colour_palette)
	assign_lookup_to_target_texture(lookup_texture)

# GENERATE the colour palette array with a texture
func generate_palette(source : Texture2D):
	var data = source.get_image() # Get pixels
	var dimensions := Vector2i(palette_image.get_width(), palette_image.get_height()); # Get dimensions
	var unique_colours = [] # Setup empty list
	
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			if data.get_pixel(x,y) in unique_colours: # If it's already here, skip this iteration
				continue
			unique_colours.append(data.get_pixel(x,y))
	
	return unique_colours # Return filled list

func generate_lookup_texture(palette):
	var new_image = Image.create(accuracy_scale * accuracy_scale, accuracy_scale, false, Image.FORMAT_RGBA8)
	
	for r in range(accuracy_scale):
		for g in range(accuracy_scale):
			for b in range(accuracy_scale):
				# Determine coordinate and colour
				var coord := Vector2i(accuracy_scale * r + g, b)
				var change_factor = 256.0 / accuracy_scale
				var colour = Vector3(r * change_factor, g * change_factor, b * change_factor)
				
				# Calculate closest colour
				var last_distance = 256.0
				for p_colour in palette:
					var colour_vec = Vector3(p_colour.r * 256.0, p_colour.g * 256.0, p_colour.b * 256.0)
					var new_distance = abs(colour_vec.distance_to(colour))
					if new_distance < last_distance:
						last_distance = new_distance
						new_image.set_pixel(coord.x, coord.y, p_colour)
	
	new_image.save_png("res://generated.png")
	
	return ImageTexture.create_from_image(new_image)

# ASSIGN to the target texture
func assign_list_to_target_texture(palette):
	# Assign to shader!
	target_texture.get_material().set_shader_parameter("palette_colours", palette)
	target_texture.get_material().set_shader_parameter("palette_size", len(palette))
func assign_lookup_to_target_texture(texture: Texture2D):
	target_texture.get_material().set_shader_parameter("lookup_texture", texture)
	target_texture.get_material().set_shader_parameter("texture_size", Vector2(texture.get_width(), texture.get_height()))
	target_texture.get_material().set_shader_parameter("accuracy_scale", accuracy_scale)
