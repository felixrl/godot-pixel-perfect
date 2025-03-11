extends Camera2D

@export var test_pixel: Node2D

func _process(delta: float) -> void:
	#print("CAMERA GLOBAL POSITION: " + str(global_position))
	var p = ceil(test_pixel.global_position.x - global_position.x - 1 + 25/2.0)
	var y = ceil(test_pixel.global_position.y - global_position.y - 1 + 25/2.0)

	#p = floor(test_pixel.global_position.x - global_position.x + 1.0/2.0)
	#var p = floor(test_pixel.global_position.x) + floor(7/2.0)
	#p = ceil(test_pixel.global_position.x - global_position.x) - 1
	print("PIXEL X COMPUTATION: " + str(p) + ", Y: " + str(y))
