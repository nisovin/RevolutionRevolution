extends Node2D

onready var parent = get_parent()

func _draw():
	#draw_line(Vector2(1, 1), Vector2(-8, -8), parent.color, 3, false)
	#draw_line(Vector2(1, -1), Vector2(-8, 8), parent.color, 3, false)
	if parent.type == "planet":
		draw_polyline([Vector2(-6, -6), Vector2.ZERO, Vector2(-6, 6)], parent.color, 3, false)
	elif parent.type == "star":
		draw_polyline([Vector2(-6, -6), Vector2.ZERO, Vector2(-6, 6)], parent.color, 4, false)
	elif parent.type == "asteroids":
		draw_polyline([Vector2(-8, -8), Vector2.ZERO, Vector2(-8, 8)], Color.lightgray, 2, false)
	elif parent.type == "exit":
		draw_polyline([Vector2(-6, -6), Vector2.ZERO, Vector2(-6, 6)], parent.color, 2, false)
		draw_polyline([Vector2(-10, -6), Vector2(-4, 0), Vector2(-10, 6)], parent.color, 2, false)
