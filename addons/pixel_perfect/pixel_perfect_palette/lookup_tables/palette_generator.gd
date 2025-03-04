class_name PaletteGenerator

## Generator for a list of colors

## Generates a PackedColorArray with all unique colors in the texture
static func generate_palette_from_texture(texture: Texture2D) -> PackedColorArray:
	var image = texture.get_image()
	var dimensions := Vector2i(texture.get_width(), texture.get_height())

	var unique_colors = []
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			var color = image.get_pixel(x, y)
			if color in unique_colors:
				continue # Skip duplicates
			unique_colors.append(color)
	return PackedColorArray(unique_colors)
