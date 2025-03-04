class_name PaletteLookupRegistry

## Interface between file system and palette look-up textures
## where palettes are referenced by named IDs

const PALETTE_REGISTRY_DIR = "res://addons/pixel_perfect/baked_lookup_textures/"

static var luts: Dictionary = {}

## Tries to fetch the look-up texture IMAGE corresponding to the supplied palette id
## Returns null if there is no palette with that id
static func find_palette_lut(palette_id: String) -> Image:
	var path = generate_path(palette_id)
	if luts.has(palette_id):
		return luts.get(palette_id)
	if FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		return image
	return null

## Saves the given IMAGE to a file with the supplied palette id
## Returns true if successful, false otherwise
static func register_palette_lut(palette_id: String, image: Image) -> bool:
	luts[palette_id] = image
	
	var path = generate_path(palette_id)
	var error = image.save_png(path)
	if error != OK:
		return false
	return true

static func generate_path(palette_id: String) -> String:
	var path = PALETTE_REGISTRY_DIR.path_join(palette_id + ".png")
	return path
