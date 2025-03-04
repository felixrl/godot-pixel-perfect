class_name ColorDistance

## Helper methods for getting distance between two colors in a color space
## Since only relative distances are needed, distance squared is used
## to avoid incurring sqrt cost

## Distance squared between two colors using RGB, treating them as XYZ
static func euclidean_distance(input_color: Color, palette_color: Color) -> float:
	var input_vector = Vector3(input_color.r, input_color.g, input_color.b)
	var palette_vector = Vector3(palette_color.r, palette_color.g, palette_color.b)
	return input_vector.distance_squared_to(palette_vector)

## Distance squared between two colors in CIELAB color space
static func cielab_distance(input_color: Color, palette_color: Color) -> float:
	var input_cielab = ColorConversion.rgb_to_cielab(input_color)
	var palette_cielab = ColorConversion.rgb_to_cielab(palette_color)
	return input_cielab.distance_squared_to(palette_cielab)
