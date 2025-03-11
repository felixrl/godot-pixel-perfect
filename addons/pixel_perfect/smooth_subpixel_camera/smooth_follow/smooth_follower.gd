class_name SmoothFollower
extends Node2D

## COMPONENT that embodies the logic for SMOOTHLY FOLLOWING a target
## WITHOUT PIXEL JITTERS in the "relative frame of reference"

## --- LOGIC NOTES ---
## PREVIOUS refers to What was I on the previous frame?
## NEXT refers to What should I be for this frame?

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

## BUG: This only works if the CAMERA UPDATES FIRST
## Essentially, we have the previous frame's data, and then we update this frame's data
## The solution would be to store the previous frame's data and then update using that?
#call_deferred("update_position", delta)
#update_position(delta)

## BUG: An issue with "transitioning" in slowing down? Where it jitters in the slow down process...
## - Can fix by raising min target velocity, at cost of smooth slow speed
## BUG: Issue like "magnetic latching" after slowing object down to zero...
## BUG: What exact tuned values?
## BUG: What about acceleration?

## BUG: Occasional discrepancy where there is jitter... Initial values are off?
## This jitter only happens at the initial, AND only happens when moving in one direction (noticed right)
## AND only occurs when the speed of players has specific values.

## Generally, CAMERA must update after PLAYER to avoid 1 frame delay and genuine lock
#global_position = target_position

## SOLVING THE ACCELERATION PROBLEM
## THESE ONLY APPLY WHEN THE CAMERA AND THE TARGET HAVE THE SAME DIRECTIONAL VELOCITY..?
## What about opposite cases?

## THEORY: IN AN ACCELERATION (THE VELOCITY OF THE TARGET IS GREATER THAN THE VELOCITY OF THE CAMERA)
## THE PIXEL DISTANCE ON SCREEN *NEVER* DECREASES. IT CAN ONLY STAY THE SAME OR INCREASE.
## IN A DECELERATION (THE VELOCITY OF THE TARGET IS LESS THAN THE VELOCITY OF THE CAMERA)
## THE PIXEL DISTANCE ON SCREEN *NEVER* INCREASES. IT CAN ONLY STAY THE SAME OR DECREASE.

## Works but:
## BUG: A way to predict and evenly space out increments of movement?

## BUG: Does not work for ODD number resolutions...
## TODO: Reincorporate subpixel logic...

const MAX_LIMIT_FOR_CONSTANT_VELOCITY = 0.15

## Calculates the optimal next position for this object such that various
## pixel difference rules are followed, including constant difference during constant velocity,
## always greater or equal difference during acceleration, and always lesser or equal difference during deceleration.
func compute_next_smooth_follow_global_position(previous_global_position: Vector2, next_anticipated_global_position: Vector2, target_marker: SmoothFollowTargetMarker) -> Vector2:
	if target_marker == null:
		return next_anticipated_global_position
	
	var follower_delta := next_anticipated_global_position - previous_global_position
	var target_delta := target_marker.previous_to_now_delta

	var previous_difference := compute_pixel_difference(previous_global_position, target_marker.previous_global_position)
	var next_difference := compute_pixel_difference(next_anticipated_global_position, target_marker.now_global_position) 

	#print("P " + str(previous_difference))
	#print("N " + str(next_difference))

	var delta_difference := abs(follower_delta.length() - target_delta.length())

	var maintain_difference_global_position: Vector2 = round(target_marker.now_global_position) + previous_difference

	var final_position := next_anticipated_global_position
	var is_constant_case_x = false
	var is_constant_case_y = false
	## BEHAVIOUR FOR X
	if not is_approx_stationary(follower_delta.x): ## If the target is NOT stationary...
		if is_moving_in_same_direction(follower_delta.x, target_delta.x): ## AND we're moving in the same direction...
			## CONSTANT (Screen location does not change)
			## [SOLUTION TO THE CONSTANT VELOCITY PROBLEM]
			if is_constant_velocity(delta_difference):
				## So we simply enforce the "constant pixel difference" rule.
				final_position = Vector2(maintain_difference_global_position.x, final_position.y)
				is_constant_case_x = true
			## ACCELERATION AWAY (Screen location is diverging)
			## [SOLUTION TO THE ACCELERATION PROBLEM]
			elif is_diverging(follower_delta.x, target_delta.x):
				## We want to have a floor boundary for the next possible pixel difference
				if abs(next_difference.x) < abs(previous_difference.x):
					final_position = Vector2(maintain_difference_global_position.x, final_position.y)
			## DECELERATION TOWARD (Screen location is converging)
			elif is_converging(follower_delta.x, target_delta.x):
				## We want to have a cap for the next possible pixel difference
				if abs(next_difference.x) > abs(previous_difference.x):
					final_position = Vector2(maintain_difference_global_position.x, final_position.y)

	## BEHAVIOUR FOR Y
	if not is_approx_stationary(follower_delta.y): ## If the target is NOT stationary...
		if is_moving_in_same_direction(follower_delta.y, target_delta.y): ## AND we're moving in the same direction...
			## CONSTANT (Screen location does not change)
			## [SOLUTION TO THE CONSTANT VELOCITY PROBLEM]
			if is_constant_velocity(delta_difference):
				## So we simply enforce the "constant pixel difference" rule.
				final_position = Vector2(final_position.x, maintain_difference_global_position.y)
				is_constant_case_y = true
			## ACCELERATION AWAY (Screen location is diverging)
			## [SOLUTION TO THE ACCELERATION PROBLEM]
			elif is_diverging(follower_delta.y, target_delta.y):
				## We want to have a floor boundary for the next possible pixel difference
				if abs(next_difference.y) < abs(previous_difference.y):
					final_position = Vector2(final_position.x, maintain_difference_global_position.y)
			## DECELERATION TOWARD (Screen location is converging)
			elif is_converging(follower_delta.y, target_delta.y):
				## We want to have a cap for the next possible pixel difference
				if abs(next_difference.y) > abs(previous_difference.y):
					final_position = Vector2(final_position.x, maintain_difference_global_position.y)

	previous_global_position = final_position

	return final_position

func compute_pixel_difference(follower_position: Vector2, target_position: Vector2) -> Vector2:
	return round(follower_position) - round(target_position)

func is_approx_stationary(axis_delta: float) -> bool:
	return round(axis_delta) == 0
func is_moving_in_same_direction(follower_axis_delta: float, target_axis_delta: float) -> bool:
	return sign(follower_axis_delta) == sign(target_axis_delta)
func is_constant_velocity(delta_difference: float) -> bool:
	return delta_difference < MAX_LIMIT_FOR_CONSTANT_VELOCITY
## Target is changing faster than self
func is_diverging(follower_axis_delta: float, target_axis_delta: float) -> bool:
	return abs(target_axis_delta) > abs(follower_axis_delta)
## Target is changing slower than self
func is_converging(follower_axis_delta: float, target_axis_delta: float) -> bool:
	return abs(target_axis_delta) < abs(follower_axis_delta)
