extends Node2D

var color = Color.white

func _draw():
	draw_line(Vector2.ZERO, Vector2(-10, -10), color, 3, false)
	draw_line(Vector2.ZERO, Vector2(-10, 10), color, 3, false)
