extends Node2D

var points = []
var colors = []

func _draw():
	draw_polygon(points, colors)
