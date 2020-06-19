extends RigidBody2D

const Bullet = preload("res://universe/CometBullet.tscn")

var color

var shoot_cooldown = 0

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

func _physics_process(delta):
	shoot_cooldown -= delta

func _on_Timer_timeout():
	if shoot_cooldown <= 0 and G.player != null and not G.player.is_dead() and G.player.position.distance_squared_to(position) < 500 * 500:
		shoot_cooldown = 2
		var dir = position.direction_to(G.player.position + G.player.linear_velocity)
		var theta = (PI / 2) / 6
		dir = dir.rotated(-theta * 3)
		for i in 7:
			var bullet = Bullet.instance()
			bullet.position = position
			bullet.fire(dir * 500)
			get_parent().add_child(bullet)
			dir = dir.rotated(theta)
		Audio.play("iceball", 0.3)
	
func generate():
	color = Color.from_hsv(G.rng.randf_range(0.5, 0.6), 0.5, 1)
	var inner_rad = G.rng.randi_range(3, 5)
	var outer_rad = G.rng.randi_range(inner_rad + 5, inner_rad + 7)
	var center = Vector2(outer_rad, outer_rad)
	var spikes = outer_rad * 3
	var theta = 2 * PI / spikes
	
	var img = Image.new()
	img.create(outer_rad * 2, outer_rad * 2, false, Image.FORMAT_RGBA8)
	img.lock()
	var t = 0
	for i in spikes / 3:
		var dir = Vector2.RIGHT.rotated(t)
		var l = G.rng.randf_range(inner_rad, outer_rad)
		for j in 3:
			var r = 0
			while r < l:
				var c = color
				c.s = 0.7 - (r / outer_rad / 2)
				var v = center + dir * r
				img.set_pixelv(v, c)
				r += 0.5
			dir = dir.rotated(2 * PI / 3)
		t += theta
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	$Sprite.texture = tex
	
	$Particles.color = color
	$Particles.amount = outer_rad * 25
	$Particles.emission_sphere_radius = inner_rad * 2
	$CollisionShape2D.shape.radius = (inner_rad + outer_rad) / 2

