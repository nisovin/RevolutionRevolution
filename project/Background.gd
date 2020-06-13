extends Node2D

const far_size = 1000
const mid_size = 1500
const near_size = 1000

onready var far_stars = $ParallaxBackground/FarStars/FarStars
onready var far_gas1 = $ParallaxBackground/FarGas/FarGas1
onready var far_gas2 = $ParallaxBackground/FarGas/FarGas2
onready var mid_stars = $ParallaxBackground/MidStars/MidStars
onready var mid_gas1 = $ParallaxBackground/MidGas/MidGas1
onready var mid_gas2 = $ParallaxBackground/MidGas/MidGas2
onready var near_stars = $ParallaxBackground/NearStars/NearStars

func _ready():
	$ParallaxBackground/FarStars.motion_mirroring = Vector2(far_size, far_size)
	$ParallaxBackground/FarGas.motion_mirroring = Vector2(far_size, far_size)
	$ParallaxBackground/MidStars.motion_mirroring = Vector2(mid_size, mid_size)
	$ParallaxBackground/MidGas.motion_mirroring = Vector2(mid_size, mid_size)
	$ParallaxBackground/NearStars.motion_mirroring = Vector2(near_size, near_size) * 2
	generate()
	
func _unhandled_key_input(event):
	if event.is_action_pressed("ui_accept"):
		generate()
		
func generate():
	
	var start = OS.get_ticks_msec()
	
	var img
	var tex
	var mat
	var color
	var hue
	
	# far stars
	img = Image.new()
	img.create(far_size, far_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(600, 1500):
		var v = Vector2(G.rng.randi_range(0, far_size), G.rng.randi_range(0, far_size))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		img.set_pixelv(v, c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	far_stars.texture = tex
	
	print("far stars ", OS.get_ticks_msec() - start)
	
	# mid stars
	img = Image.new()
	img.create(mid_size, mid_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(400, 800):
		var v = Vector2(G.rng.randi_range(0, mid_size), G.rng.randi_range(0, mid_size))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		var type = G.rng.randi_range(0, 10)
		img.set_pixelv(v, c)
		if (type == 0 || type == 1) and v.x < mid_size - 2 and v.y < mid_size - 2:
			img.set_pixelv(v + Vector2.RIGHT, c)
			img.set_pixelv(v + Vector2.DOWN, c)
			img.set_pixelv(v + Vector2.ONE, c)
		elif (type == 2 || type == 3) and v.x < mid_size - 2 and v.y < mid_size - 2:
			img.set_pixelv(v + Vector2.LEFT, c)
			img.set_pixelv(v + Vector2.DOWN, c)
			img.set_pixelv(v + Vector2.UP, c)
			img.set_pixelv(v + Vector2.RIGHT, c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	mid_stars.texture = tex
	
	print("mid  stars ", OS.get_ticks_msec() - start)
	
	# near stars
	img = Image.new()
	img.create(near_size, near_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(50, 150):
		var v = Vector2(G.rng.randi_range(0, near_size), G.rng.randi_range(0, near_size))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		var type = G.rng.randi_range(0, 10)
		img.set_pixelv(v, c)
		if (type == 0 || type == 1) and v.x < near_size - 2 and v.y < near_size - 2:
			img.set_pixelv(v + Vector2.RIGHT, c)
			img.set_pixelv(v + Vector2.DOWN, c)
			img.set_pixelv(v + Vector2.ONE, c)
		elif (type == 2 || type == 3) and v.x < near_size - 2 and v.y < near_size - 2:
			img.set_pixelv(v + Vector2.LEFT, c)
			img.set_pixelv(v + Vector2.DOWN, c)
			img.set_pixelv(v + Vector2.UP, c)
			img.set_pixelv(v + Vector2.RIGHT, c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	near_stars.texture = tex
	
	print("near stars ", OS.get_ticks_msec() - start)
	
	# gasses
	tex = ImageTexture.new()
	tex.create(far_size / 2, far_size / 2, Image.FORMAT_RGB8, Texture.FLAG_REPEAT)
	far_gas1.texture = tex
	tex = ImageTexture.new()
	tex.create(far_size / 2, far_size / 2, Image.FORMAT_RGB8, Texture.FLAG_REPEAT)
	far_gas2.texture = tex
	tex = ImageTexture.new()
	tex.create(mid_size / 2, mid_size / 2, Image.FORMAT_RGB8, Texture.FLAG_REPEAT)
	mid_gas1.texture = tex
	tex = ImageTexture.new()
	tex.create(mid_size / 2, mid_size / 2, Image.FORMAT_RGB8, Texture.FLAG_REPEAT)
	mid_gas2.texture = tex
	var noise = OpenSimplexNoise.new()
		
	print("gas setup ", OS.get_ticks_msec() - start)
	
	# far gas
	noise.lacunarity = 4.0
	noise.period = G.rng.randf_range(70, 200)
	noise.seed = G.rng.randi()
	img = noise.get_seamless_image(far_size / 2)
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	hue = G.rng.randf_range(0.6, 1.6)
	if hue > 1: hue -= 1
	color = Color.from_hsv(hue, G.rng.randf_range(0.2, 0.4), G.rng.randf_range(0.7, 1.0))
	mat = far_gas1.material
	mat.set_shader_param("color", color)
	mat.set_shader_param("fade", G.rng.randf_range(0.4, 0.7))
	mat.set_shader_param("noise_texture", tex)
	
	noise.seed = G.rng.randi()
	img = noise.get_seamless_image(far_size / 2)
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	hue = color.h + G.rng.randf_range(-0.3, 0.3)
	if hue > 1: hue -= 1
	elif hue < 0: hue += 1
	color.h = hue
	mat = far_gas2.material
	mat.set_shader_param("color", color)
	mat.set_shader_param("fade", G.rng.randf_range(0.4, 0.7))
	mat.set_shader_param("noise_texture", tex)
	
	print("far gas ", OS.get_ticks_msec() - start)

	# mid gas
	noise.lacunarity = 3.0
	noise.period = G.rng.randf_range(100, 300)
	noise.seed = G.rng.randi()
	img = noise.get_seamless_image(mid_size / 2)
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	hue = G.rng.randf_range(0.6, 1.6)
	if hue > 1: hue -= 1
	color = Color.from_hsv(hue, G.rng.randf_range(0.2, 0.4), G.rng.randf_range(0.7, 1.0))
	mat = mid_gas1.material
	mat.set_shader_param("color", color)
	mat.set_shader_param("fade", G.rng.randf_range(0.5, 0.8))
	mat.set_shader_param("noise_texture", tex)

	
	noise.seed = G.rng.randi()
	img = noise.get_seamless_image(mid_size / 2)
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	hue = color.h + G.rng.randf_range(-0.3, 0.3)
	if hue > 1: hue -= 1
	elif hue < 0: hue += 1
	color.h = hue
	mat = mid_gas2.material
	mat.set_shader_param("color", color)
	mat.set_shader_param("fade", G.rng.randf_range(0.4, 0.7))
	mat.set_shader_param("noise_texture", tex)

	print("mid gas ", OS.get_ticks_msec() - start)
