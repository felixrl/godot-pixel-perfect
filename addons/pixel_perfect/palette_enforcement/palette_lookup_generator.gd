class_name PaletteLookupGenerator 

const BAKED_LOOKUP_TEXTURES_DIR = "res://addons/pixel_perfect/baked_lookup_textures/"

const EUCLIDEAN_FILE_NAME = "euclidean_lookup.png"
const CIELAB_FILE_NAME = "cielab_lookup.png"

## Generate a lookup texture using Euclidian distance on RGB values
static func get_euclidian_lookup_texture(palette: Array, accuracy_scale: int) -> ImageTexture:
	var path = BAKED_LOOKUP_TEXTURES_DIR.path_join(EUCLIDEAN_FILE_NAME)
	
	var new_image
	if (FileAccess.file_exists(path)):
		new_image = Image.load_from_file(path)
	else:
		new_image = generate_lookup_image(palette, accuracy_scale, _euclidean_distance)
		new_image.save_png(path)
	
	return ImageTexture.create_from_image(new_image)

## Generate a lookup texture using CIELAB distance on supplied colours
static func get_cielab_lookup_texture(palette: Array, accuracy_scale: int) -> ImageTexture:
	var path = BAKED_LOOKUP_TEXTURES_DIR.path_join(CIELAB_FILE_NAME)
	
	var new_image
	if (FileAccess.file_exists(path)):
		new_image = Image.load_from_file(path)
	else:
		new_image = generate_lookup_image(palette, accuracy_scale, _cielab_distance)
		new_image.save_png(path)
	
	return ImageTexture.create_from_image(new_image)

## Generate a lookup texture as an IMAGE 
## using the supplied distance function on RGB values. 
## The distance function takes two colors 
## and returns a float that represents the distance between them
static func generate_lookup_image(palette: Array, accuracy_scale: int, distance_function: Callable) -> Image:
	var width = accuracy_scale * accuracy_scale
	var height = accuracy_scale
	var new_image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for r in range(accuracy_scale):
		for g in range(accuracy_scale):
			for b in range(accuracy_scale):
				# Flatten so that red and green share the x channel
				# (w * r + g, b)
				var lookup_coords := Vector2i(accuracy_scale * r + g, b) 
				
				# Compute RGB color from accuracy scale loop, in the range [0, 1] 
				var input_color = Color(float(r) / accuracy_scale, float(g) / accuracy_scale, float(b) / accuracy_scale)
				
				var closest_color: Color
				var last_distance = INF
				for palette_color in palette:
					var new_distance = distance_function.call(input_color, palette_color)
					if new_distance < last_distance:
						last_distance = new_distance
						closest_color = palette_color
				
				new_image.set_pixel(lookup_coords.x, lookup_coords.y, closest_color)
	return new_image

## Distance functions in colour space
static func _euclidean_distance(input_color: Color, palette_color: Color) -> float:
	var input_vector = Vector3(input_color.r, input_color.g, input_color.b)
	var palette_vector = Vector3(palette_color.r, palette_color.g, palette_color.b)
	return input_vector.distance_squared_to(palette_vector)

static func _cielab_distance(input_color: Color, palette_color: Color) -> float:
	var input_cielab = ColorConversion.rgb_to_cielab(input_color)
	var palette_cielab = ColorConversion.rgb_to_cielab(palette_color)
	return input_cielab.distance_squared_to(palette_cielab)
