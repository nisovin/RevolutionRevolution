extends Node2D

var damage = 5
var max_distance = 5000

var radius = G.rng.randf_range(80, 120)
var arc = G.rng.randf_range(PI/6, PI/4)
var points = G.rng.randi_range(3, 7)
var width = G.rng.randi_range(5, 10)

func _ready():
	var origin = Vector2(-radius, 0)
	var top = origin + Vector2.RIGHT.rotated(-arc) * (radius + width)
	var topmid = origin + Vector2.RIGHT.rotated(-arc/2) * (radius + width)
	var mid = origin + Vector2.RIGHT * (radius + width + width)
	var botmid = origin + Vector2.RIGHT.rotated(arc/2) * (radius + width)
	var bot = origin + Vector2.RIGHT.rotated(arc) * (radius + width)
	$CollisionShape2D.shape.points = [top * 2, topmid * 2, mid, botmid * 2, bot * 2]

func _on_SolarFlare_body_entered(body):
	body.take_damage(damage)

func _on_Timer_timeout():
	if global_position.length_squared() > max_distance * max_distance:
		queue_free()
