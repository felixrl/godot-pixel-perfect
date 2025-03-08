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
	
	#print(round(smooth_global_position) - round(smooth_global_position.lerp(target_position, delta * 12.0)))
	
	var next_smooth_global_position = MathUtil.decay(smooth_global_position, target_position, 24.0, delta)
	#print(next_smooth_global_position)
	#print("B" + str(smooth_global_position))
	#print("C" + str(follow_node.get_instantaneous_velocity(delta)))
	
	var my_velocity: Vector2 = next_smooth_global_position - smooth_global_position
	
	var current_difference: Vector2 = get_rounded_global_position() - round(follow_node.my_global_position) 
	var next_difference: Vector2 = round(next_smooth_global_position) - round(follow_node.get_next_global_position(delta))
	
	#print(current_difference.is_equal_approx(next_difference))
	
	var difference_equal := current_difference.is_equal_approx(next_difference)
	var velocity_difference = abs(my_velocity.length() - follow_node.get_instantaneous_velocity(delta).length())
	
	print(velocity_difference)
	var MIN_VELOCITY := 0.5
	var CONSTANT_VELOCITY_CRITERIA := 1.0
	
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
	
	## BUG: An issue with "transitioning" in slowing down? Where it jitters in the slow down process...
	## BUG: What exact tuned values?
	## BUG: What about moving "back"/slowing down? Only do this when moving in the SAME GENERAL DIRECTION?
	
	#print(follow_node.get_instantaneous_velocity(delta).is_zero_approx())
	
	## TOOD: Split into individual x and y fields?
	
	## If the camera should be moving at constant velocity relative to the moving target...
	if follow_node.get_instantaneous_velocity(delta).length() > 0.5 and velocity_difference < CONSTANT_VELOCITY_CRITERIA:
		## MAINTAIN DIFFERENCE
		set_smooth_global_position(current_difference + round(follow_node.get_next_global_position(delta)))
	else: ## Can just accelerate towards...
		set_smooth_global_position(next_smooth_global_position)

	#set_smooth_global_position(next_smooth_global_position)

	# BUG: Doesn't work for ACCELERATION time
	# HOW TO TEST for CONSTANT VELOCITY???
	#smooth_global_position = target_position
