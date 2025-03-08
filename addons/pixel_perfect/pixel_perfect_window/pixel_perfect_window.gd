@tool
class_name PixelPerfectWindow
extends Control

## NODE that SETS UP and CONFIGURES necessary elements for a PIXEL PERFECT (SUB-VIEWPORT) WINDOW

## TODO: DEALING WITH MOUSE INPUT!

## The viewport that contains the world to render for this window
@export var source_viewport: SubViewport

## The native resolution to be used
@export var native_resolution: Vector2i = Vector2i(640, 360)

## Resizer to use for this window
@export var resizer: PixelPerfectResizer
## Aligner to use for this window
@export var aligner: PixelPerfectAligner

@export_category("Details")

## Enables the clipped offset of the window's visuals to make camera motions appear smooth
@export var use_subpixel_smoothing: bool = true
## Whether or not this window should have alpha
@export var use_transparency: bool = true

var scale_factor: int = 1
var margins: Vector2 = Vector2.ZERO

@onready var texture_rect: PixelPerfectWindowTextureRect = %PixelPerfectWindowTextureRect
@onready var viewport_handler: PixelPerfectWindowViewportHandler = %PixelPerfectWindowViewportHandler

func _ready() -> void:
	init_config_details()
	
	viewport_handler.viewport = source_viewport
	if viewport_handler.has_viewport():
		texture_rect.set_texture(viewport_handler.get_viewport_texture())

func init_config_details() -> void:
	size = native_resolution
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_PASS

func _process(delta: float) -> void:
	init_config_details()
	
	## SETTING VALUES
	var final_native_resolution = native_resolution
	var texture_rect_local_position = Vector2.ZERO
	
	if use_subpixel_smoothing:
		## Add 1 pixel on each boundary to pad out
		final_native_resolution += Vector2i(2, 2)
		## Shift offset by 1 pixel so that it remains centred
		texture_rect_local_position += Vector2(-1, -1)
	
	viewport_handler.set_viewport_resolution(final_native_resolution)
	texture_rect.set_size(final_native_resolution)
	texture_rect.set_position(texture_rect_local_position)
	
	if resizer != null:
		scale_factor = resizer.compute_scale_factor(native_resolution)
	else:
		scale_factor = 1
	scale = Vector2(scale_factor, scale_factor)
	if aligner != null:
		position = aligner.compute_margins(native_resolution * scale_factor)
	else:
		position = Vector2.ZERO

	if use_subpixel_smoothing:
		update_subpixel_smoothing()

func update_subpixel_smoothing():
	if viewport_handler.has_subpixel_camera():
		var camera: SubpixelCamera = viewport_handler.get_viewport_camera_2d() as SubpixelCamera
		texture_rect.set_subpixel_offset(camera.subpixel_offset)

const PALETTE_SHADER: Shader = preload("res://addons/pixel_perfect/pixel_perfect_palette/shaders/palette_lookup.gdshader")

## Assign the palette LUT and relevant config to the texture rect's shader
func set_palette_lut(lut: ImageTexture) -> void:
	var accuracy_scale = lut.get_height()
	texture_rect.get_shader_material().set_shader(PALETTE_SHADER)
	texture_rect.get_shader_material().set_shader_parameter("lookup_texture", lut)
	texture_rect.get_shader_material().set_shader_parameter("texture_size", Vector2(lut.get_width(), lut.get_height()))
	texture_rect.get_shader_material().set_shader_parameter("accuracy_scale", accuracy_scale)
	texture_rect.get_shader_material().set_shader_parameter("use_transparency", use_transparency)

#region MOUSE INPUT

func _unhandled_input(event: InputEvent) -> void:
	PixelPerfect.get_mouse_screen_position()

#endregion
