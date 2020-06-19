extends Area2D

signal collected

var xp = 1
var rotation_speed = G.rng.randf_range(-2 * PI, 2 * PI)
var hue = G.rng.randf_range(0.65, 0.8)

func _ready():
	var point_count = G.rng.randi_range(5, 7)
	var inner_rad = G.rng.randf_range(4, 6)
	var outer_rad = G.rng.randf_range(8, 12) + inner_rad
	var mid_rad = (inner_rad + outer_rad) / 2
	var theta = 2 * PI / point_count
	
	var points = []
	var colors = []
	var alpha = 0
	for i in point_count:
		points.append(Vector2.RIGHT.rotated(alpha) * inner_rad)
		colors.append(Color.from_hsv(hue + G.rng.randf_range(-0.05, 0.05), G.rng.randf_range(0.4, 0.5), 1))
		alpha += theta / 2
		points.append(Vector2.RIGHT.rotated(alpha) * G.rng.randf_range(mid_rad, outer_rad))
		colors.append(Color.from_hsv(hue + G.rng.randf_range(-0.05, 0.05), G.rng.randf_range(0.9, 1.0), 1))
		alpha += theta / 2

	$Polygon2D.polygon = points
	$Polygon2D.vertex_colors = colors
	$Polygon2D.rotation = G.rng.randf_range(0, 2 * PI)
	$CollisionShape2D.shape.radius = outer_rad

func _process(delta):
	rotation += rotation_speed * delta

func _on_MoonFood_body_entered(body):
	if body == G.player:
		G.player.collect_food(xp)
		emit_signal("collected", self)
		hide()
