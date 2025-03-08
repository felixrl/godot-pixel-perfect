@tool
class_name PixelPerfectAligner
extends Node

## ABSTRACT BASE CLASS for components which compute margins for alignment

## OVERRIDE THIS!!!
func compute_margins(resolution: Vector2i) -> Vector2:
	return Vector2.ZERO
