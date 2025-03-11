extends Sprite2D

const INCREMENT = 5.0

func _ready() -> void:
	#global_position += Vector2(PI/2.0, PI/2.0)
	pass

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		global_position += Vector2.LEFT * INCREMENT * delta
	if Input.is_action_pressed("ui_right"):
		global_position += Vector2.RIGHT * INCREMENT * delta
	if Input.is_action_pressed("ui_up"):
		global_position += Vector2.UP * INCREMENT * delta
	if Input.is_action_pressed("ui_down"):
		global_position += Vector2.DOWN * INCREMENT * delta
	
	#print("PIXEL'S GLOBAL POSITION: " + str(global_position))
