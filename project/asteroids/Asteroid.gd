extends RigidBody2D

enum State { ORBITING, CAPTURING, CAPTURED, FIRE, PROJECTILE, DEAD }

var state = State.ORBITING
var size = 5
var color
var speed = 100
var points = []
var colors = []
var dist = 0

var revolve_dir = 1
var captor = null
var rot = 0
var fire_vel

func _integrate_forces(_state):
	if state == State.ORBITING:
		var expected = position.normalized() * dist
		var target = expected + (position.normalized().rotated(PI / 2 * revolve_dir) * 200)
		var dir = position.direction_to(target)
		applied_force = dir * speed * mass
	elif state == State.CAPTURED:
		var target = captor.position + (Vector2.RIGHT.rotated(rot) * dist)
		var dir = position.direction_to(target)
		var d = position.distance_to(target)
		applied_force = dir * speed * (d / 5) * mass
	elif state == State.FIRE:
		applied_force = fire_vel * mass
		_state.linear_velocity = fire_vel * 5
		state = State.PROJECTILE
		
func _physics_process(delta):
	if state == State.CAPTURED:
		rot += 2 * PI * delta / 5

func clear_layers():
	collision_layer = 0
	collision_mask = 0

func capture(t):
	if state != State.ORBITING: return false
	state = State.CAPTURED
	captor = t
	dist = G.rng.randf_range(size * 3, 175)
	rot = G.rng.randf_range(0, 2 * PI)
	call_deferred("clear_layers")
	$Dialog.text = G.rand_dialog("asteroid")
	$Tween.interpolate_property($Dialog, "modulate", Color.transparent, Color.white, 0.3)
	$Tween.interpolate_property($Dialog, "modulate", Color.white, Color.transparent, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.5)
	$Tween.start()
	return true
	
func fire(vel):
	state = State.FIRE
	fire_vel = vel
	$Sprite.modulate = Color.red
	set_deferred("collision_layer", 8)
	set_deferred("collision_mask", 2)
	set_deferred("contact_monitor", true)
	set_deferred("contacts_reported", 1)
	
func generate():
	dist = position.length()
	size = G.rng.randi_range(2, 6)
	mass = size * 0.5
	if G.rng.randf() < 0.2:
		size *= 2
		if G.rng.randf() < 0.1:
			size *= 2
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
	
	apply_torque_impulse(G.rng.randf_range(-20, 20))
	
func _on_Asteroid_body_entered(body):
	if state == State.PROJECTILE and body.is_in_group("planets"):
		Audio.play("break", 0.4)
		body.get_parent().take_damage(size)
		queue_free()
