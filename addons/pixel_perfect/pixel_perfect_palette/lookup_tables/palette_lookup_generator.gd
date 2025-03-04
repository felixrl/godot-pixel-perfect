class_name PaletteLookupGenerator 

## Generator for palette LUT IMAGES

## Generate a lookup texture IMAGE using Euclidian distance on RGB values
static func generate_euclidian_lookup_texture(colors: PackedColorArray, accuracy_scale: int) -> Image:
	var new_image: Image = generate_lookup_image(colors, accuracy_scale, ColorDistance.euclidean_distance)
	return new_image

## Generate a lookup texture IMAGE using CIELAB distance on supplied colors
static func generate_cielab_lookup_texture(colors: PackedColorArray, accuracy_scale: int) -> Image:
	var new_image: Image = generate_lookup_image(colors, accuracy_scale, ColorDistance.cielab_distance)
	return new_image

## Generate a lookup texture as an IMAGE 
## using the supplied distance function on RGB values. 
## The distance function takes two colors 
## and returns a float that represents the distance between them.
## Accuracy scale specifies how many increments there are for each channel of R, G, and B
static func generate_lookup_image(colors: PackedColorArray, accuracy_scale: int, distance_function: Callable) -> Image:
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
				for color in colors:
					var new_distance = distance_function.call(input_color, color)
					if new_distance < last_distance:
						last_distance = new_distance
						closest_color = color
				
				new_image.set_pixel(lookup_coords.x, lookup_coords.y, closest_color)
	return new_image
