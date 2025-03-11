extends Sprite2D

var time: float = 0

func _process(delta):
	rotation_degrees += 10 * delta
	
	print(get_viewport_rect())
	# time += delta
	# position = Vector2(0, -sin(time) * 32)
	
	# global_position = PixelPerfect.get_cursor_world_position_relative_to($"../Camera".position)
	# print(global_position)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#print("MAN " + str(event.global_position))
		global_position = event.global_position
