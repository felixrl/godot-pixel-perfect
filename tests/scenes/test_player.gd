class_name TestPlayer
extends Sprite2D

const SPEED = 255.0
const ACCELERATION = 1000.0

var velocity := Vector2.ZERO
var input_direction := Vector2.ZERO

@onready var my_position := position
@onready var my_global_position := global_position

@export var follow_target: SmoothFollowTargetMarker

var next_position

func _ready() -> void:
	my_global_position += Vector2(0.01, 0.01)
	#pass

func _process(delta: float) -> void:
	input_direction = Vector2.ZERO
	input_direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	#if Input.is_action_pressed("ui_up"):
		#input_direction += Vector2.UP
	#if Input.is_action_pressed("ui_down"):
		#input_direction += Vector2.DOWN
	#if Input.is_action_pressed("ui_left"):
		#input_direction += Vector2.LEFT
	#if Input.is_action_pressed("ui_right"):
		#input_direction += Vector2.RIGHT

var previous_direction: Vector2
func _physics_process(delta: float) -> void:
	velocity = MathUtil.decay(velocity, input_direction.normalized() * SPEED, ACCELERATION, delta)
	
	my_global_position = get_next_global_position(delta)
	global_position = my_global_position
	
	#follow_target.set_now_global_position(global_position)
	if input_direction.length() > 0.1:
		previous_direction = input_direction
	
	follow_target.now_global_position = global_position + previous_direction.normalized() * 100.0
	
	#print("TEST PLAYER: " + str(my_global_position) + " and real " + str(global_position))
	
	#print("ANOTHER 2 " + str(MyCamera.count))


## NOTE: INSTANTENOUS VELOCITY IS THE WRONG TERM
## Should be "delta position"
func get_instantaneous_velocity(delta: float) -> Vector2:
	return velocity * delta
func get_next_global_position(delta: float) -> Vector2:
	return my_global_position + get_instantaneous_velocity(delta)
