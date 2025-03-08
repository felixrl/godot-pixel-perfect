@tool
class_name PixelPerfectResizer
extends Node

## ABSTRACT BASE CLASS for encapsulating functionality
## involved in resizing a window

## OVERRIDE THIS!!!
func compute_scale_factor(native_resolution: Vector2i) -> float:
	return 1.0
	pass

## TODO: Optimization by using even callback sometime somewhere...
#func _ready() -> void:
	#get_tree().get_root().connect("size_changed", resize)
	#resize()
