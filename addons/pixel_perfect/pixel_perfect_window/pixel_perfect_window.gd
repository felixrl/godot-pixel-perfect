@tool
class_name PixelPerfectWindow
extends Control

## A node that encapsulates a texture rect that renders a viewport in pixel perfect
## with clipping

## TODO: DEALING WITH MOUSE INPUT!
## NOTE: Transparency toggle with enforcement??
## NOTE: Save data to this object and then load to children to prevent data loss

@export var source_viewport: SubViewport
@export var native_resolution: Vector2i = Vector2i(640, 360)
var scale_factor: int = 1
var margins: Vector2 = Vector2.ZERO

@onready var texture_rect: TextureRect = %TextureRect

func _ready() -> void:
	if has_viewport():
		texture_rect.set_texture(source_viewport.get_texture())
	texture_rect.texture_filter = TextureFilter.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	size = native_resolution
	clip_contents = true
	
	if source_viewport != null:
		source_viewport.size = native_resolution + Vector2i(2, 2)
	texture_rect.size = native_resolution + Vector2i(2, 2)
	
	scale = Vector2(scale_factor, scale_factor)
	position = margins
	texture_rect.position = Vector2(-1, -1)
	
	if has_subpixel_camera():
		var camera: SubpixelCamera = get_viewport_camera_2d()
		get_shader_material().set_shader_parameter("camera_offset", camera.subpixel_offset)

## FROM VIEWPORT...

func has_viewport() -> bool:
	return source_viewport != null
func has_camera() -> bool:
	return has_viewport() && source_viewport.get_camera_2d() != null
func has_subpixel_camera() -> bool:
	return has_camera() && source_viewport.get_camera_2d() is SubpixelCamera

func get_viewport_camera_2d() -> Camera2D:
	if has_camera():
		return source_viewport.get_camera_2d()
	return null

func get_shader_material() -> Material:
	if (texture_rect.get_material() == null):
		texture_rect.set_material(ShaderMaterial.new())
	return texture_rect.get_material()
