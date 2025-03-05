@tool
class_name PixelPerfectWindow
extends TextureRect

## A node that encapsulates a texture rect that renders a viewport in pixel perfect

## TODO Smooth scrolling
## TODO: DEALING WITH MOUSE INPUT!
## NOTE: Transparency toggle with enforcement??

@export var source_viewport: SubViewport
@export var native_resolution: Vector2i = Vector2i(640, 360)
var scale_factor: int = 1
var margins: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_texture(source_viewport.get_texture())
	
	texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	if source_viewport != null:
		source_viewport.size = native_resolution + Vector2i(2, 2)
	size = native_resolution + Vector2i(2, 2)
	
	scale = Vector2(scale_factor, scale_factor)
	position = margins - Vector2(1, 1)
	
	var camera = source_viewport.get_camera_2d()
	if (camera != null):
		if "subpixel_offset" in camera:
			print(camera.subpixel_offset)
			get_shader_material().set_shader_parameter("camera_offset", -camera.subpixel_offset)

func get_shader_material() -> Material:
	if (get_material() == null):
		set_material(ShaderMaterial.new())
	return get_material()
