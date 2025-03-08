@tool
class_name PixelPerfectPalette
extends Node

## A node that encapsulates the necessary functionality for enforcing
## palettes on viewport textures

## TODO: Split bake and regular functionality
## TODO: Non-LUT systems
## TODO: Make LUT system work for build?
## BUG: LUT system DOES NOT work (well, at least) for anything beyond 128 accuracy
## LIKELY BECAUSE TEXTURE IS TOO BIG
## - Don't use LUT, or
## - Split between multiple LUTs

enum DistanceFunction {
	## Simple distance squared directly on RGB
	EUCLIDEAN,
	## Conversion to CIELAB colour space before distance squared calculation
	CIELAB
}

## Window to which the shader and palette will be applied
@export var window: PixelPerfectWindow

@export_category("Palette Generation")
## Texture used to dynamically produce a list of unique colours for the palette
@export var palette_texture: Texture2D

## Number of "pixel" units to allocate each RGB range in the lookup texture
@export_range(0, 256) var accuracy_scale: int = 128

@export_category("Baking")

## ID for the palette
@export var palette_id: String = "default_palette"

## Selected method for comparing two colours and determining which one has a smaller visual difference
@export var distance_function: DistanceFunction

## TOOL TOGGLE: When toggled to true, bakes the supplied palette texture to the given id lookup table
@export var bake_palette := false : set = _set_bake_palette
func _set_bake_palette(value: bool):
	if (value):
		var return_value = bake()
		if return_value != 0:
			print("Bake failed with code " + str(return_value))
		else:
			print("Bake completed with code " + str(return_value))
		print("---")
	bake_palette = false

var palette
var lookup_texture
var previous_distance_function

func _ready() -> void:
	swap_to(palette_id)

## Bakes the palette from palette_texture into palette_id (on the registry)
## Returns 0 on success and any other number on error
func bake() -> int:
	print("---")
	print("Baking palette with id \"" + palette_id + "\"...")
	
	## GENERATE COLORS
	if palette_texture == null:
		print("ERROR! No palette texture is assigned.")
		return 1
	var colors: PackedColorArray = PaletteGenerator.generate_palette_from_texture(palette_texture)
	print("- Generated PackedColorArray from \"" + palette_texture.resource_path + "\".")
	
	## GENERATE LUTS
	var new_image
	match distance_function:
		DistanceFunction.EUCLIDEAN:
			new_image = PaletteLookupGenerator.generate_euclidian_lookup_texture(colors, accuracy_scale)
			print("- Using EUCLIDEAN color distance.")
		DistanceFunction.CIELAB:
			new_image = PaletteLookupGenerator.generate_cielab_lookup_texture(colors, accuracy_scale)
			print("- Using CIELAB color distance.")
		_:
			print("ERROR! Invalid distance function.")
			return 2
	
	## REGISTER
	var success = PaletteLookupRegistry.register_palette_lut(palette_id, new_image)
	if not success:
		print("ERROR! An issue occured while registering the palette.")
		return 3
	print("- Registed the palette!")
	
	## SWAP TO THE NEW PALETTE
	swap_to(palette_id)
	
	return 0

## TODO: More uniform palette hotswapping system
## TODO: Pre-load into memory all palettes/LUTs into registry
## Swaps to the palette associated with the new palette id if it's in the registry.
## Prints an error and returns early if there is no palette with that id
func swap_to(new_palette_id: String) -> void:
	var lut_image: Image = PaletteLookupRegistry.find_palette_lut(new_palette_id)
	if lut_image == null:
		print("ERROR! Cannot load palette with id \"" + new_palette_id + "\" because it is not in the registry.")
		return
	lookup_texture = ImageTexture.create_from_image(lut_image)
	_assign_lookup_texture_to_windows()

## Update lookup texture with metadata and shader for every referenced layer
func _assign_lookup_texture_to_windows():
	window.set_palette_lut(lookup_texture)
