class_name PaletteNode
extends Node

enum DistanceFunction {
	EUCLIDEAN,
	CIELAB
}

@export var rect: PixelPerfectRect

@export var palette_texture: Texture2D
@export var distance_function: DistanceFunction
@export var accuracy_scale: int = 128

@export var palette_shader: Shader

var palette
var lookup_texture

func _ready() -> void:
	palette = _generate_palette_from_texture(palette_texture)
	lookup_texture = _get_lookup_texture(distance_function)
	_assign_lookup_texture(rect.get_material(), lookup_texture, accuracy_scale)

## Get the lookup texture specified by the distance function
func _get_lookup_texture(function: DistanceFunction) -> ImageTexture:
	match function:
		DistanceFunction.EUCLIDEAN:
			return PaletteLookupGenerator.get_euclidian_lookup_texture(palette, accuracy_scale)
		DistanceFunction.CIELAB:
			return PaletteLookupGenerator.get_cielab_lookup_texture(palette, accuracy_scale)
	
	push_error("Invalid distance function in palette node")
	return null

## Generate a color palette from a texture by accumulating all unique colors
func _generate_palette_from_texture(source_texture: Texture2D):
	# Get image
	var data = source_texture.get_image()
	# Get dimensions
	var dimensions := Vector2i(source_texture.get_width(), source_texture.get_height())

	var unique_colors = []
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			var color = data.get_pixel(x, y)
			# Skip duplicates
			if color in unique_colors:
				continue
			unique_colors.append(color)
	return unique_colors

## Assign the lookup texture shader and corresponding metadata to a palette material
func _assign_lookup_texture(shader_material: ShaderMaterial, lookup_texture: Texture2D, accuracy_scale: int):
	shader_material.set_shader(palette_shader)
	shader_material.set_shader_parameter("lookup_texture", lookup_texture)
	shader_material.set_shader_parameter("texture_size", Vector2(lookup_texture.get_width(), lookup_texture.get_height()))
	shader_material.set_shader_parameter("accuracy_scale", accuracy_scale)
