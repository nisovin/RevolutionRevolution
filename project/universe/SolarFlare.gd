extends Node2D

var damage = 10

var radius = G.rng.randf_range(80, 120)
var arc = G.rng.randf_range(PI/6, PI/4)
var points = G.rng.randi_range(4, 7)
var width = G.rng.randi_range(5, 10)

var velocity

func _ready():
	generate()

func fire(vel):
	velocity = vel
	rotation = vel.angle()

func _physics_process(delta):
	position += velocity * delta
	
func generate():
	var origin = Vector2(-radius, 0)
	var top = origin + Vector2.RIGHT.rotated(-arc) * (radius + width)
	var topmid = origin + Vector2.RIGHT.rotated(-arc/2) * (radius + width)
	var mid = origin + Vector2.RIGHT * (radius + width + width)
	var botmid = origin + Vector2.RIGHT.rotated(arc/2) * (radius + width)
	var bot = origin + Vector2.RIGHT.rotated(arc) * (radius + width)
	var points = [top * 2, topmid * 2, mid, botmid * 2, bot * 2]
	$CollisionShape2D.shape.points = points
	
	var ppoints = []
	var pcolors = []
	var a = -arc
	var p
	while a < arc:
		p = origin + Vector2.RIGHT.rotated(a) * (radius + width / 2.0)
		ppoints.append(p * 2)
		pcolors.append(Color.orange)
		a += PI / 50
	p = origin + Vector2.RIGHT.rotated(a) * (radius + width / 2.0)
	ppoints.append(p * 2)
	pcolors.append(Color.orange)
	$Particles.emission_points = PoolVector2Array(ppoints)
	print(ppoints)
	#$Particles.emission_colors = PoolColorArray(pcolors)
#
#	for p in ppoints:
#		var sprite = Sprite.new()
#		sprite.texture = load("res://icon.png")
#		sprite.position = p
#		sprite.scale = Vector2(.1, .1)
#		add_child(sprite)
	
	

func _on_SolarFlare_body_entered(body):
	print("flare damage!")
	body.take_damage(damage)
	Audio.play("sunhit")

func _on_Timer_timeout():
	queue_free()
