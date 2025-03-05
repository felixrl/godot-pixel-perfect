@tool
class_name PixelPerfectResizer
extends Node

## A node that encapsulates the functionality for centering and resizing
## a PixelPerfectWindow

## Windows to which the resizer will be applied
## NOTE: All windows will gain the same native resolution
@export var windows: Array[PixelPerfectWindow]

## The native resolution
@export var native_resolution: Vector2i = Vector2i(640, 360)
## Should the windows be centred in screen space?
@export var is_centred := false
## Scale factor, from (0, INF)
var scale_factor: int = 1
## Margins from top-left corner, specifying the total XY offset
var margins: Vector2

func _ready() -> void:
	get_tree().get_root().connect("size_changed", resize)
	resize()

func _process(delta: float) -> void:
	#resize()
	pass

## Callback on window resize...
func resize():
	var screen_resolution = get_viewport().size
	scale_factor = compute_scale_factor(screen_resolution)
	margins = compute_margins(screen_resolution)
	
	for window: PixelPerfectWindow in windows:
		window.native_resolution = native_resolution
		window.scale_factor = scale_factor
		if is_centred:
			window.margins = margins
		else:
			window.margins = Vector2.ZERO

#region COMPUTATIONS

## Calculate the max possible scale factor given a screen size
func compute_scale_factor(screen_size: Vector2i):
	var temp_scale_factor = 1
	while (native_resolution * temp_scale_factor).x <= screen_size.x and (native_resolution * temp_scale_factor).y <= screen_size.y: # Increasing when smaller than dimensions, goes to one over
		temp_scale_factor += 1
	return temp_scale_factor - 1 # Return the size that fits within the screen

## Calculate the margins to centre the screen
func compute_margins(screen_size):
	var x_margin = (screen_size.x - (scale_factor * native_resolution).x) / 2.0 # Position at center of window (difference of screen and upscaled divided by 2 since there are 2 margins)
	var y_margin = (screen_size.y - (scale_factor * native_resolution).y) / 2.0
	return Vector2(x_margin, y_margin)

## Calculate maximum scale factor in the screen display
func compute_max_scale_factor():
	var max_screen_size = DisplayServer.screen_get_size()
	return compute_scale_factor(max_screen_size) - 1

#endregion
