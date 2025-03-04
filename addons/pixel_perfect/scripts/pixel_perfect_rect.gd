#class_name PixelPerfectRectE extends TextureRect
#
### PIXEL PERFECT RECT
### Update rect details with size, scale, and position
### Process mouse inputs
#
#@onready var mouse_area: Area2D = $Area2D
#@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
#
#var sub_viewport_node : SubViewport = null
#
### UPDATE LOGIC
#func update_rect(pixel_perfect: PixelPerfectNode):
	#size = pixel_perfect.native_pixel_res # Set to native resolution
	#scale = Vector2(pixel_perfect.scale_factor, pixel_perfect.scale_factor) # Set scale factor
	#position = pixel_perfect.margins + pixel_perfect.pixel_offset # Set position to centre with offset
	#_update_area()
#func _update_area():
	#collision_shape.shape.size = size
#
### MOUSE INPUT
#var is_mouse_inside := false
#func _on_mouse_entered() -> void:
	#is_mouse_inside = true
#func _on_mouse_exited() -> void:
	#is_mouse_inside = false
#func _input(event: InputEvent) -> void:
	#if not is_instance_valid(sub_viewport_node):
		#return
	#
	#if not is_instance_of(event, InputEventMouseMotion):
		#return
	#
	##if not is_mouse_inside:
		##return
	#
	#event.global_position = PixelPerfect.get_mouse_world_pixel_position()
	#event.position = PixelPerfect.get_mouse_world_pixel_position()
	#sub_viewport_node.push_input(event)
#
### KEY AND THE REST INPUT
#func _unhandled_input(event: InputEvent) -> void:
	#for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		#if is_instance_of(event, mouse_event):
			#return
	#if is_instance_valid(sub_viewport_node):
		#sub_viewport_node.push_input(event)
