@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("PixelPerfect", "res://addons/pixel_perfect/pixel_perfect_global.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("PixelPerfect")
