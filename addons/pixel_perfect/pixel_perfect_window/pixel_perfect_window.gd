@tool
class_name PixelPerfectWindow
extends TextureRect

## A node that encapsulates a texture rect that renders a viewport in pixel perfect

## TODO Smooth scrolling
## TODO Optional transparency
## TODO: DEALING WITH MOUSE INPUT!

@export var source_viewport: SubViewport
@export var native_resolution: Vector2i = Vector2i(640, 360)
var scale_factor: int = 1
var margins: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_texture(source_viewport.get_texture())
	
	texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	if source_viewport != null:
		source_viewport.size = native_resolution
	size = native_resolution
	
	scale = Vector2(scale_factor, scale_factor)
	position = margins

func get_shader_material() -> Material:
	if (get_material() == null):
		set_material(ShaderMaterial.new())
	return get_material()
