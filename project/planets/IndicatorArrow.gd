extends Node2D

func _draw():
	if owner.type == "planet":
		draw_polyline([Vector2(-8, -8), Vector2.ZERO, Vector2(-8, 8)], owner.color, 4, false)
	elif owner.type == "star":
		draw_polyline([Vector2(-10, -12), Vector2.ZERO, Vector2(-10, 12)], owner.color, 6, false)
	elif owner.type == "asteroids":
		draw_polyline([Vector2(-6, -12), Vector2.ZERO, Vector2(-6, 12)], Color.lightgray, 2, false)
	elif owner.type == "food":
		draw_circle(Vector2.ZERO, 4, owner.color)
	elif owner.type == "exit":
		draw_polyline([Vector2(-6, -6), Vector2.ZERO, Vector2(-6, 6)], owner.color, 2, false)
		draw_polyline([Vector2(-10, -6), Vector2(-4, 0), Vector2(-10, 6)], owner.color, 2, false)
