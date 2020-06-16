extends Node2D

func _draw():
	for i in owner.width:
		var c = Color.from_hsv(G.rng.randf_range(0.038, 0.166), 1, 1)
		draw_arc(Vector2(-owner.radius, 0), owner.radius + i, -owner.arc, owner.arc, owner.points, c, 2, false)
#
#	var interval = arc * 2 / (points - 1)
#	var theta = -arc + interval / 2
#	for i in points - 1:
#		var p = Vector2(-radius, 0) + Vector2.RIGHT.rotated(theta) * (radius + 10)
#		var c = Vector2(-radius, 0).move_toward(p, radius / 2)
#		draw_arc(c, radius / 2 + 10, -arc/points, arc/points, 3, Color.yellow, 2, false)
#		#draw_circle(, 3, Color.red)
#		theta += interval
