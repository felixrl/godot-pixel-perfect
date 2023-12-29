extends Sprite2D

var time: float = 0

func _process(delta):
	rotation_degrees += 10 * delta
	
	time += delta
	position = Vector2(0, -sin(time) * 32)
