extends KinematicBody2D

var radius = 0
var health = 25
var dead = false

func _ready():
	$CollisionShape2D.shape.radius = radius

func _draw():
	var color = Color.from_hsv(G.rng.randf_range(0, 1), G.rng.randf_range(0.25, 0.5), 1, 0.5)
	var r = radius
	for i in G.rng.randi_range(8, 10):
		color.h += G.rng.randf_range(-0.05, 0.05)
		draw_arc(Vector2.ZERO, r, 0, 2 * PI, radius * PI, color, 1.3)
		r -= G.rng.randf_range(2, 3.5)
			
func take_damage(amt):
	if dead: return
	health -= amt
	get_parent().emit_signal("attacked", self, amt, health)
	if health <= 0:
		dead = true
		G.score += 5
		Audio.play("ringbreak")
		$Tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 0.2)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		queue_free()
