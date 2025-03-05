extends Sprite2D

const SPEED = 200.0
const ACCELERATION = 10.0

var velocity := Vector2.ZERO
var input_direction := Vector2.ZERO

func _process(delta: float) -> void:
	input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		input_direction += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		input_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		input_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		input_direction += Vector2.RIGHT

func _physics_process(delta: float) -> void:
	velocity = velocity.lerp(input_direction * SPEED, delta * ACCELERATION)
	
	position += velocity * delta
