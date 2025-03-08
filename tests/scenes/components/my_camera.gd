class_name MyCamera
extends SubpixelCamera

@export var follow_node: TestPlayer

const LERP_RATE = 5.0
var target_position: Vector2 = Vector2.ZERO

## Updating position is most ideal in physics process?
func _physics_process(delta: float) -> void:
	if follow_node != null:
		target_position = follow_node.my_global_position
	
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
	decay_toward_target_with_constant_velocity_fix(delta)
	
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

const MIN_TARGET_VELOCITY = 0.5
const MAX_LIMIT_FOR_CONSTANT_VELOCITY = 0.15

const MAINTAIN_INCREASE_AMOUNT = 3.0
const MAINTAIN_THRESHOLD = 0.2

var use_maintain_x := 0.0 : set = set_maintain_x
func set_maintain_x(value) -> void:
	use_maintain_x = clamp(value, 0.0, 1.0)
var use_maintain_y := 0.0 : set = set_maintain_y
func set_maintain_y(value) -> void:
	use_maintain_y = clamp(value, 0.0, 1.0)

func decay_toward_target_with_constant_velocity_fix(delta: float) -> void:
	## THIS IS THE GENERIC SMOOTHING BEHAVIOUR...
	## "Where do I WANT to go next?"
	var next_smooth_global_position = MathUtil.decay(smooth_global_position, target_position, LERP_RATE, delta)
	
	## Compute difference (final - initial) from now to then to see the instantenous "change"
	var instant_velocity: Vector2 = next_smooth_global_position - smooth_global_position
	## Retrieve INSTANTANEOUS VELOCITY from target
	## Get the same instantenous change from the target...
	var target_instant_velocity: Vector2 = follow_node.get_instantaneous_velocity(delta)
	
	## The current PIXEL POSITION DIFFERENCE
	var current_difference: Vector2 = get_rounded_global_position() - round(follow_node.my_global_position) 
	## The next PIXEL POSITION DIFFERENCE
	var next_difference: Vector2 = round(next_smooth_global_position) - round(follow_node.get_next_global_position(delta))

	var velocity_difference = abs(instant_velocity.length() - target_instant_velocity.length())
	#var velocity_difference = instant_velocity - target_instant_velocity

	var next_position_to_maintain_difference = current_difference + round(follow_node.get_next_global_position(delta))
	
	var final_position = next_smooth_global_position
	
	var is_constant_case_x = false
	var is_constant_case_y = false
	## BEHAVIOUR FOR X
	if round(target_instant_velocity.x) != 0: ## If the target is NOT stationary...
		if sign(instant_velocity.x) == sign(target_instant_velocity.x): ## AND we're moving in the same direction...
			## CONSTANT (Screen location does not change)
			## [SOLUTION TO THE CONSTANT VELOCITY PROBLEM]
			if is_constant_velocity(velocity_difference):
				## So we simply enforce the "constant pixel difference" rule.
				final_position = Vector2(next_position_to_maintain_difference.x, final_position.y)
				is_constant_case_x = true
			## ACCELERATION AWAY (Screen location is diverging)
			## [SOLUTION TO THE ACCELERATION PROBLEM]
			elif abs(target_instant_velocity.x) > abs(instant_velocity.x):
				## We want to have a floor boundary for the next possible pixel difference
				if abs(next_difference.x) < abs(current_difference.x):
					final_position = Vector2(next_position_to_maintain_difference.x, final_position.y)
			## DECELERATION TOWARD (Screen location is converging)
			elif abs(target_instant_velocity.x) < abs(instant_velocity.x):
				## We want to have a cap for the next possible pixel difference
				if abs(next_difference.x) > abs(current_difference.x):
					final_position = Vector2(next_position_to_maintain_difference.x, final_position.y)
	
	## BEHAVIOUR FOR Y
	if round(target_instant_velocity.y) != 0: ## If the target is NOT stationary...
		if sign(instant_velocity.y) == sign(target_instant_velocity.y): ## AND we're moving in the same direction...
			## CONSTANT (Screen location does not change)
			## [SOLUTION TO THE CONSTANT VELOCITY PROBLEM]
			if is_constant_velocity(velocity_difference):
				## So we simply enforce the "constant pixel difference" rule.
				final_position = Vector2(final_position.x, next_position_to_maintain_difference.y)
				is_constant_case_y = true
			## ACCELERATION AWAY (Screen location is diverging)
			## [SOLUTION TO THE ACCELERATION PROBLEM]
			elif abs(target_instant_velocity.y) > abs(instant_velocity.y):
				## We want to have a floor boundary for the next possible pixel difference
				if abs(next_difference.y) < abs(current_difference.y):
					final_position = Vector2(final_position.x, next_position_to_maintain_difference.y)
			## DECELERATION TOWARD (Screen location is converging)
			elif abs(target_instant_velocity.y) < abs(instant_velocity.y):
				## We want to have a cap for the next possible pixel difference
				if abs(next_difference.y) > abs(current_difference.y):
					final_position = Vector2(final_position.x, next_position_to_maintain_difference.y)
	
	var previous_subpixel = subpixel_offset
	
	set_smooth_global_position(final_position)
	
	## BUG: Why does subpixel have to be uniform..? To avoid diagonal jitter...
	if is_constant_case_x: ## BUG: Fixing subpixel jitters on constant velo...
		## This has to be the last thing called, so that it overrides! (OR make a subpixel override feature)
		#subpixel_offset = Vector2(previous_subpixel.x, subpixel_offset.y)
		subpixel_offset = previous_subpixel
	if is_constant_case_y:
		#subpixel_offset = Vector2(subpixel_offset.x, previous_subpixel.y)
		subpixel_offset = previous_subpixel

func is_constant_velocity(velocity_length_difference: float) -> bool:
	return velocity_length_difference < MAX_LIMIT_FOR_CONSTANT_VELOCITY
