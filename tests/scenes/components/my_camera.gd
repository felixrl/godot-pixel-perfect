class_name MyCamera
extends SubpixelCamera

@export var follow_node: TestPlayer

const LERP_RATE = 10.0
var target_position: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		target_position = Vector2(RandomNumberGenerator.new().randf_range(-32, 32), RandomNumberGenerator.new().randf_range(-32, 32))

## Updating position is most ideal in physics process?
func _physics_process(delta: float) -> void:
	if follow_node != null:
		target_position = follow_node.global_position
	
	## THE PRINCIPLE OF FIXING STUTTER AT EQUAL VELOCITY
	## ---
	## When the target is (absolutely) stationary 
	## or accelerating relative to the camera reference frame,
	## we can use simple smooth motion.
	## (There will be a little jitter, but since acceleration is a "transitory" state it should be fine)
	## ---
	## However, if the target and the camera have similar CONSTANT VELOCITIES...
	## (The target appears "stationary" in the camera's reference frame)
	## ...the relative (pixel) difference between the camera's centre and the target
	## MUST REMAIN EQUAL.
	## ---
	
	## This should be broken down to be analyzed on the axis level.
	## (Per x or y)
	## ---
	## CONDITION
	## - The target HAS TO BE MOVING (velocity != 0) 
	## That is the [NOT STATIONARY CLAUSE]
	## - The camera HAS TO BE MOVING WITH SOME MINIMUM SPEED (camVelocity > minCamVelocity)
	## (Is this necessary?????)
	## - The difference between velocities is LESS THAN A CERTAIN THRESHOLD
	## That is the [CONSTANT VELOCITY CLAUSE]
	## ---
	## CALCULATION
	## The next smooth position is the TARGET'S NEXT ROUNDED PIXEL POSITION
	## plus the CURRENT DIFFERENCE between the CAMERA'S PIXEL POSITION and the TARGET'S CURRENT PIXEL POSITION
	## (This is solved by algebra)
	## OR consider: start with the next position of the target, 
	## and maintain the same pixel offset (in the same direction).
	decay_toward_target_with_constant_velocity_fix(delta)
	
	## BUG: An issue with "transitioning" in slowing down? Where it jitters in the slow down process...
	## BUG: What exact tuned values?
	## BUG: What about moving "back"/slowing down? Only do this when moving in the SAME GENERAL DIRECTION?
	## BUG: What about acceleration?

const MIN_TARGET_VELOCITY = 0.5
const MAX_LIMIT_FOR_CONSTANT_VELOCITY = 1.0
func decay_toward_target_with_constant_velocity_fix(delta: float) -> void:
	## Decay!
	var next_smooth_global_position = MathUtil.decay(smooth_global_position, target_position, LERP_RATE, delta)
	
	## Get difference from current as INSTANTANEOUS VELOCITY
	var instant_velocity: Vector2 = next_smooth_global_position - smooth_global_position
	## Retrieve INSTANTENOUS VELOCITY from target
	var target_instant_velocity: Vector2 = follow_node.get_instantaneous_velocity(delta)
	
	## The current PIXEL POSITION DIFFERENCE
	var current_difference: Vector2 = get_rounded_global_position() - round(follow_node.my_global_position) 
	## The next PIXEL POSITION DIFFERENCE
	var next_difference: Vector2 = round(next_smooth_global_position) - round(follow_node.get_next_global_position(delta))

	var velocity_difference = abs(instant_velocity.length() - target_instant_velocity.length())
	#var velocity_difference = instant_velocity - target_instant_velocity

	var next_position_to_maintain = current_difference + round(follow_node.get_next_global_position(delta))

	var final_position = next_smooth_global_position
	## BEHAVIOUR FOR X
	if abs(target_instant_velocity.x) > MIN_TARGET_VELOCITY and velocity_difference < MAX_LIMIT_FOR_CONSTANT_VELOCITY and sign(instant_velocity.x) == sign(target_instant_velocity.x):
		print("here")
		final_position = Vector2(next_position_to_maintain.x, final_position.y)
	## BEHAVIOUR FOR Y
	if abs(target_instant_velocity.y) > MIN_TARGET_VELOCITY and velocity_difference < MAX_LIMIT_FOR_CONSTANT_VELOCITY and sign(instant_velocity.y) == sign(target_instant_velocity.y):
		final_position = Vector2(final_position.x, next_position_to_maintain.y)
	set_smooth_global_position(final_position)
