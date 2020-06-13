extends Node2D

var revolve_around = null
var revolve_speed = 1

var diameter = 0
var base_color = Color.white

func _process(delta):
	if revolve_around != null:
		var v = position - revolve_around.position
		v = v.rotated(deg2rad(revolve_speed) * delta)
		position = revolve_around.position + v
		

func generate(star = false):
	var image = Image.new()
	
	var radius = G.rng.randi_range(15, 40)
	if star: radius = G.rng.randi_range(80, 150)
	diameter = radius * 2 + 1
	var rad_sq = radius * radius
	var center = Vector2(radius, radius)
	print(radius)
	
	if star:
		base_color = Color.from_hsv(G.rng.randf_range(0.05, 0.17), 1.0, G.rng.randf_range(0.8, 1.0))
	else:
		base_color = Color.from_hsv(G.rng.randf_range(0.3, 0.95), G.rng.randf_range(0.8, 1.0), G.rng.randf_range(0.5, 0.9))
	var color_points = []
	for i in G.rng.randi_range(2, radius / 10):
		var c
		if G.rng.randf() < .5:
			c = base_color.darkened(G.rng.randf_range(0.1, 0.2))
		else:
			c = base_color.lightened(G.rng.randf_range(0.1, 0.2))
		var h = c.h
		if star:
			h += G.rng.randf_range(-0.04, 0.04)
			if h > 0.17: h = 0.17
		else:
			h += G.rng.randf_range(-0.2, 0.2)
		if h < 0: h += 1.0
		elif h > 1: h -= 1.0
		c.h = h
		var p = center + Vector2(radius, radius).rotated(G.rng.randf_range(0, 2 * PI))
		color_points.append({"color": c, "point": p})
	
#	var rect = ColorRect.new()
#	rect.rect_size = Vector2(50, 20)
#	rect.color = base_color
#	add_child(rect)
#	for p in color_points.size():
#		rect = ColorRect.new()
#		rect.rect_size = Vector2(50, 20)
#		rect.rect_position = Vector2(0, 25 * (p+1))
#		rect.color = color_points[p].color
#		add_child(rect)
	
	image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	image.lock()
	for x in range(1, diameter - 1):
		for y in range(1, diameter - 1):
			var v = Vector2(x, y)
			if v.distance_squared_to(center) <= rad_sq:
				var color = base_color
				for p in color_points:
					var pct = v.distance_squared_to(p.point) / (diameter*diameter) / 1.5
					var c = p.color
					color = color.blend(Color(c.r, c.g, c.b, pct))
				image.set_pixelv(v, color)
			else:
				image.set_pixelv(v, Color.transparent)
	image.unlock()
	
	$Sprite.texture = ImageTexture.new()
	$Sprite.texture.create_from_image(image, 0)
	
	if star:
		$Sprite.material = null
		return
	
	var noise = OpenSimplexNoise.new()
	noise.seed = G.rng.randi()
	noise.lacunarity = G.rng.randf_range(2.0, 4.0)
	#noise.octaves = G.rng.randi_range(2, 5)
	noise.period = G.rng.randf_range(20, 100)
	noise.persistence = G.rng.randf_range(0.25, 0.75)
	print(noise.lacunarity, " ", noise.octaves, " ", noise.period, " ", noise.persistence)
	var noise_img = noise.get_seamless_image(diameter * 2)
	var noise_tex = ImageTexture.new()
	noise_tex.create_from_image(noise_img, 0)

	var over_color = Color()
	over_color = over_color.from_hsv(G.rng.randf_range(0.3, 0.95), G.rng.randf_range(0.3, 0.7), G.rng.randf_range(0.5, 0.9))

#	rect = ColorRect.new()
#	rect.rect_size = Vector2(50, 20)
#	rect.rect_position = Vector2(60, 0)
#	rect.color = over_color
#	add_child(rect)
	
	var mat = $Sprite.material as ShaderMaterial
	mat.set_shader_param("color", over_color)
	mat.set_shader_param("speed", G.rng.randf_range(0.3, 1.0) * 1 if G.rng.randf() < 0.5 else -1)
	mat.set_shader_param("density", G.rng.randf_range(0.3, 0.6))
	mat.set_shader_param("noise_texture", noise_tex)

	if G.rng.randf() < 0.2:
		$Sprite.rotation = PI / 2
	else:
		$Sprite.rotation = 0
