class_name SmoothFollowTargetMarker
extends Marker2D

## COMPONENT that embodies a target position that a SMOOTH FOLLOWER is trying to get to

var previous_global_position: Vector2
var previous_to_now_delta: Vector2 = Vector2.ZERO

signal updated

@onready var now_global_position: Vector2 = global_position : set = set_now_global_position
func set_now_global_position(value: Vector2) -> void:
	previous_global_position = now_global_position
	now_global_position = value
	## FINAL - INITIAL
	#print("I WAS UPDATED")
	previous_to_now_delta = now_global_position - previous_global_position
	updated.emit()
func set_now_position(value: Vector2) -> void:
	now_global_position = to_global(value)

func _physics_process(delta: float) -> void:
	#print("ANOTHER " + str(MyCamera.count))
	pass
