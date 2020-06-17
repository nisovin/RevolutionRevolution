extends RigidBody2D

var color

func _ready():
	generate()

func _integrate_forces(state):
	if G.player != null:
		applied_force = position.direction_to(G.player.position) * 300
		var v = linear_velocity.length_squared()
		if v > 800 * 800:
			linear_velocity = linear_velocity.normalized() * 800
		elif v > 0 and v < 200 * 200:
			linear_velocity = linear_velocity.normalized() * 200
		$Particles.rotation = linear_velocity.angle() + PI
		print(linear_velocity.length())

func generate2():
	pass

	var inner_rad = G.rng.randi_range(6, 9)
	var outer_rad = G.rng.randi_range(inner_rad + 2, inner_rad + 5)
	var point_count = G.rng.randi_range(4, 7)
	
	var center = Vector2(outer_rad, outer_rad)
	var points = []
	var interval = 2 * PI / point_count
	
	for i in point_count:
		var angle = i * interval + G.rng.randf_range(0, interval / 3)
		var offset = Vector2.RIGHT.rotated(angle) * outer_rad
		points.append(center + offset)
	
	
func generate():
	color = Color.from_hsv(G.rng.randf_range(0.5, 0.6), 0.5, 1)
	var inner_rad = G.rng.randi_range(3, 5)
	var outer_rad = G.rng.randi_range(inner_rad + 5, inner_rad + 7)
	var center = Vector2(outer_rad, outer_rad)
	var spikes = outer_rad * 2
	var theta = 2 * PI / spikes
	
	var img = Image.new()
	img.create(outer_rad * 2, outer_rad * 2, false, Image.FORMAT_RGBA8)
	img.lock()
	var t = 0
	for i in spikes:
		var dir = Vector2.RIGHT.rotated(t)
		var l = G.rng.randf_range(inner_rad, outer_rad)
		var r = 0
		while r < l:
			var c = color
			c.s = 0.7 - (r / outer_rad / 2)
			var v = center + dir * r
			img.set_pixelv(v, c)
			r += 0.5
		t += theta
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	$Sprite.texture = tex
	
	$Particles.color = color
	$Particles.amount = outer_rad * 25
	$Particles.emission_sphere_radius = inner_rad * 2
	$CollisionShape2D.shape.radius = (inner_rad + outer_rad) / 2
