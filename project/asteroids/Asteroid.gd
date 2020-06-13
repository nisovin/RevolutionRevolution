extends RigidBody2D

enum State { ORBITING, CAPTURED, FIRE, PROJECTILE, DEAD }

var state = State.ORBITING
var size = 5
var color
var speed = 100
var points = []
var colors = []
var dist = 0

var captor = null
var rot = 0
var fire_dir

func _integrate_forces(_state):
	if state == State.ORBITING:
		var expected = position.normalized() * dist
		var target = expected + (position.normalized().rotated(PI / 2) * 200)
		var dir = position.direction_to(target)
		applied_force = dir * speed
	elif state == State.CAPTURED:
		var target = captor.position + (Vector2.RIGHT.rotated(rot) * dist)
		var dir = position.direction_to(target)
		var d = position.distance_to(target)
		applied_force = dir * speed * (d / 5)
	elif state == State.FIRE:
		applied_force = fire_dir * speed * 5
		_state.linear_velocity = fire_dir * speed * 20
		state = State.PROJECTILE
		
func _physics_process(delta):
	if state == State.CAPTURED:
		rot += 2 * PI * delta / 5
		
func capture(t):
	if state != State.ORBITING: return false
	print("capturing", self)
	state = State.CAPTURED
	captor = t
	dist = captor.position.distance_to(position) * 0.7
	if dist < size * 3:
		dist = size * 3
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	return true
	
func fire(dir):
	state = State.FIRE
	fire_dir = dir
	set_deferred("collision_layer", 8)
	set_deferred("collision_mask", 2)
	set_deferred("contact_monitor", true)
	set_deferred("contacts_reported", 1)
	
func generate():
	dist = position.length()
	size = G.rng.randi_range(2, 12)
	#mass = PI * size * size
	speed = G.rng.randf_range(25, 50)
	color = Color.from_hsv(G.rng.randf_range(0.05, 0.2), G.rng.randf_range(0.05, 0.25), G.rng.randf_range(0.4, 0.7))
	var count = G.rng.randi_range(4, 4 + size / 3)
	var phi = PI * 2 / count
	var theta = 0
	for i in count:
		theta += G.rng.randf_range(phi - 0.3, phi + 0.3)
		var point = Vector2.RIGHT.rotated(theta) * G.rng.randf_range(size * .8, size)
		points.append(point)
		var c = color
		c.s += G.rng.randf_range(-0.04, 0.04)
		c.v += G.rng.randf_range(-0.1, 0.1)
		colors.append(c)
	
	$Sprite.points = points
	$Sprite.colors = colors
	$Sprite.update()

	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = size * 2 * 0.9
	
func _on_Asteroid_body_entered(body):
	print("collide")
	if state == State.PROJECTILE and body.is_in_group("planets"):
		print("ouch")
		queue_free()
