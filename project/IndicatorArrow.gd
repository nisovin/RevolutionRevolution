extends Node2D

onready var parent = get_parent()

func _draw():
	#draw_line(Vector2(1, 1), Vector2(-8, -8), parent.color, 3, false)
	#draw_line(Vector2(1, -1), Vector2(-8, 8), parent.color, 3, false)
	draw_polyline([Vector2(-6, -6), Vector2.ZERO, Vector2(-6, 6)], parent.color, 3, false)
