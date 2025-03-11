@tool
class_name PixelPerfectWindowInputHandler
extends Area2D

@onready var window: PixelPerfectWindow = get_parent()
var is_mouse_inside := false

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var transformer: PixelPerfectTransformer = %PixelPerfectTransformer

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	transformer.window = window

func set_collision_rect(dimensions: Vector2i) -> void:
	var rect = collision_shape_2d.shape as RectangleShape2D
	rect.size = dimensions
	collision_shape_2d.shape = rect

func _on_mouse_entered() -> void:
	is_mouse_inside = true
func _on_mouse_exited() -> void:
	is_mouse_inside = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_of(event, InputEventMouseMotion):
		return ## We don't handle other stuff here.
	
	#print(get_global_mouse_position())
	#event.global_position = 
	#event.position = transformer.screen_to_unclamped_relative_world(get_global_mouse_position())
	
	#print(" and " + str(event.global_position))
	
	if window.viewport_handler.has_viewport():
		var new_event = event.duplicate()
		new_event.global_position = transformer.screen_to_unclamped_absolute_world(get_global_mouse_position())
		window.viewport_handler.viewport.push_input(new_event, true)
