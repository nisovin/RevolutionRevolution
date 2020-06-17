extends Area2D

var velocity
var rot

func fire(vel):
	velocity = vel
	rot = G.rng.randf_range(-4 * PI, 4 * PI)
	
func _physics_process(delta):
	position += velocity * delta
	rotation += rot * delta

func _on_CometBullet_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(5)
		Audio.play("comethit")
	queue_free()

func _on_Timer_timeout():
	queue_free()
