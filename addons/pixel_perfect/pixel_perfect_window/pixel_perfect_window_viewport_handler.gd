@tool
class_name PixelPerfectWindowViewportHandler
extends Node

## COMPONENT NODE that handles CONFIGURING and OBSERVING the state of the viewport

var viewport: SubViewport

## Sets the "native resolution" of the viewport
## in terms of NATIVE pixels
func set_viewport_resolution(resolution: Vector2i) -> void:
	if has_viewport():
		viewport.size = resolution
func get_viewport_resolution() -> Vector2i:
	if has_viewport():
		return viewport.size
	return Vector2i.ZERO

func get_viewport_texture() -> Texture2D:
	if has_viewport():
		return viewport.get_texture()
	return null

func has_viewport() -> bool:
	return viewport != null

#region CAMERA

func get_viewport_camera_2d() -> Camera2D:
	if has_camera_2d():
		return viewport.get_camera_2d()
	return null
func has_camera_2d() -> bool:
	return has_viewport() && viewport.get_camera_2d() != null
## Is the camera specifically a SUBPIXEL camera?
func has_subpixel_camera() -> bool:
	return has_camera_2d() && viewport.get_camera_2d() is SubpixelCamera

#endregion
