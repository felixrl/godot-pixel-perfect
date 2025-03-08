@tool
class_name PixelPerfectWindowTextureRect
extends TextureRect

## COMPONENT NODE that RENDERS the viewport texture

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_PASS

func set_subpixel_offset(offset: Vector2) -> void:
	var material := get_shader_material()
	material.set_shader_parameter("camera_offset", offset)

#region MATERIAL

## Gets the material if its a ShaderMaterial.
## Otherwise, creates a new blank ShaderMaterial
func get_shader_material() -> ShaderMaterial:
	if not has_material() or not (get_material() is ShaderMaterial):
		set_material(ShaderMaterial.new())
	return get_material()

func has_material() -> bool:
	return get_material() != null

#endregion
