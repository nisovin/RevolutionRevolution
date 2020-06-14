extends Node2D

enum State { NORMAL, WARP }

const far_size = 1000
const mid_size = 1500
const near_size = 1000

var fast = false
var state = State.NORMAL
var warp_dir = Vector2.ZERO

onready var warp_stars = $ParallaxBackground/WarpSpeed/Stars
onready var far_stars = $ParallaxBackground/FarStars/FarStars
onready var far_stars2 = $ParallaxBackground/FarStars2/FarStars
onready var far_gas1 = $ParallaxBackground/FarGas/FarGas1
onready var far_gas2 = $ParallaxBackground/FarGas/FarGas2
onready var mid_stars = $ParallaxBackground/MidStars/MidStars
onready var mid_gas1 = $ParallaxBackground/MidGas/MidGas1
onready var mid_gas2 = $ParallaxBackground/MidGas/MidGas2
onready var near_stars = $ParallaxBackground/NearStars/NearStars

func _ready():
	$ParallaxBackground/WarpSpeed.motion_mirroring = Vector2(far_size, far_size)
	$ParallaxBackground/FarStars.motion_mirroring = Vector2(far_size, far_size)
	$ParallaxBackground/FarStars2.motion_mirroring = Vector2(far_size, far_size)
	$ParallaxBackground/FarGas.motion_mirroring = Vector2(far_size, far_size)
	$ParallaxBackground/MidStars.motion_mirroring = Vector2(mid_size, mid_size)
	$ParallaxBackground/MidGas.motion_mirroring = Vector2(mid_size, mid_size)
	$ParallaxBackground/NearStars.motion_mirroring = Vector2(near_size, near_size) * 2
	
	for child in $ParallaxBackground.get_children():
		for sprite in child.get_children():
			sprite.position = child.motion_mirroring / 2
		#child.motion_offset = child.motion_mirroring / -2
	
func _process(delta):
	if state == State.WARP:
		$ParallaxBackground/WarpSpeed.motion_offset += warp_dir * 1500 * delta
	
	if Input.is_action_just_pressed("ui_home"):
		generate()
	
func goto_warp(dir):
	if state == State.WARP: return
	state = State.WARP
	warp_dir = -dir
	$Tween.interpolate_property(far_stars, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(far_stars2, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(far_gas1, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(far_gas2, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(mid_stars, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(mid_gas1, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(far_gas1, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(mid_gas2, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(near_stars, "modulate", Color.white, Color.transparent, 1)
	$Tween.interpolate_property(warp_stars, "modulate", Color.transparent, Color.white, 1)
	$Tween.start()

func goto_normal():
	if state == State.NORMAL: return
	$Tween.interpolate_property(far_stars, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(far_stars2, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(far_gas1, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(far_gas2, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(mid_stars, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(mid_gas1, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(far_gas1, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(mid_gas2, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(near_stars, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property(warp_stars, "modulate", Color.white, Color.transparent, 1)
	$Tween.start()
	yield(get_tree().create_timer(1), "timeout")
	state = State.NORMAL
		
func generate():
	
	var start = OS.get_ticks_msec()
	
	var img
	var tex
	var mat
	var color
	var hue
	
	# warp speed
	img = Image.new()
	img.create(far_size, far_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(1000, 2000):
		var v = Vector2(G.rng.randi_range(1, far_size - 1), G.rng.randi_range(1, far_size - 1))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		img.set_pixelv(v, c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	warp_stars.texture = tex
	yield(get_tree(), "idle_frame")
	
	# far stars
	img = Image.new()
	img.create(far_size, far_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(600, 1500):
		var v = Vector2(G.rng.randi_range(1, far_size - 1), G.rng.randi_range(1, far_size - 1))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		img.set_pixelv(v, c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	far_stars.texture = tex
	yield(get_tree(), "idle_frame")
	
	# far stars 2
	img = Image.new()
	img.create(far_size, far_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(500, 1000):
		var v = Vector2(G.rng.randi_range(1, far_size - 1), G.rng.randi_range(1, far_size - 1))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		img.set_pixelv(v, c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	far_stars2.texture = tex
	yield(get_tree(), "idle_frame")
		
	# mid stars
	img = Image.new()
	img.create(mid_size, mid_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(400, 800):
		var v = Vector2(G.rng.randi_range(1, mid_size - 3), G.rng.randi_range(1, mid_size - 3))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), 1.0)
		var type = G.rng.randi_range(0, 12)
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
		elif (type == 4) and v.x < mid_size - 3 and v.y < mid_size - 3:
			img.set_pixelv(v + Vector2(1,1), c)
			img.set_pixelv(v + Vector2(2,2), c)
			img.set_pixelv(v + Vector2(0,2), c)
			img.set_pixelv(v + Vector2(2,0), c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	mid_stars.texture = tex
	yield(get_tree(), "idle_frame")
		
	# near stars
	img = Image.new()
	img.create(near_size, near_size, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in G.rng.randi_range(150, 250):
		var v = Vector2(G.rng.randi_range(1, near_size - 3), G.rng.randi_range(1, near_size - 3))
		var h = G.rng.randf_range(0.5, 1.16)
		if h > 1: h -= 1
		var c = Color.from_hsv(h, G.rng.randf_range(0, 0.3), G.rng.randf_range(0.2, 0.5))
		var type = G.rng.randi_range(0, 15)
		img.set_pixelv(v, c)
		if (type == 0 || type == 1 || type == 2) and v.x < near_size - 2 and v.y < near_size - 2:
			img.set_pixelv(v + Vector2.RIGHT, c)
			img.set_pixelv(v + Vector2.DOWN, c)
			img.set_pixelv(v + Vector2.ONE, c)
		elif (type == 3) and v.x < near_size - 2 and v.y < near_size - 2:
			img.set_pixelv(v + Vector2.LEFT, c)
			img.set_pixelv(v + Vector2.DOWN, c)
			img.set_pixelv(v + Vector2.UP, c)
			img.set_pixelv(v + Vector2.RIGHT, c)
		elif (type == 4) and v.x < mid_size - 3 and v.y < mid_size - 3:
			img.set_pixelv(v + Vector2(1,1), c)
			img.set_pixelv(v + Vector2(2,2), c)
			img.set_pixelv(v + Vector2(0,2), c)
			img.set_pixelv(v + Vector2(2,0), c)
	img.unlock()
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	near_stars.texture = tex
	yield(get_tree(), "idle_frame")
	
	if fast:
		$ParallaxBackground/FarGas.queue_free()
		$ParallaxBackground/MidGas.queue_free()
		return
	
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
	yield(get_tree(), "idle_frame")
	
	# far gas
	noise.lacunarity = 4.0
	noise.period = G.rng.randf_range(70, 200)
	noise.seed = G.rng.randi()
	img = noise.get_seamless_image(far_size / 2)
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	hue = G.rng.randf_range(0.5, 1.2)
	if hue > 1: hue -= 1
	color = Color.from_hsv(hue, G.rng.randf_range(0.2, 0.5), G.rng.randf_range(0.7, 1.0))
	mat = far_gas1.material
	mat.set_shader_param("color", color)
	mat.set_shader_param("fade", G.rng.randf_range(0.2, 0.9))
	mat.set_shader_param("noise_texture", tex)
	yield(get_tree(), "idle_frame")
	
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
	mat.set_shader_param("fade", G.rng.randf_range(0.2, 0.9))
	mat.set_shader_param("noise_texture", tex)
	yield(get_tree(), "idle_frame")
	
	# mid gas
	noise.lacunarity = 3.0
	noise.period = G.rng.randf_range(100, 300)
	noise.seed = G.rng.randi()
	img = noise.get_seamless_image(mid_size / 2)
	tex = ImageTexture.new()
	tex.create_from_image(img, Texture.FLAG_REPEAT)
	hue = G.rng.randf_range(0.5, 1.2)
	if hue > 1: hue -= 1
	color = Color.from_hsv(hue, G.rng.randf_range(0.2, 0.7), G.rng.randf_range(0.7, 1.0))
	mat = mid_gas1.material
	mat.set_shader_param("color", color)
	mat.set_shader_param("fade", G.rng.randf_range(0.5, 0.8))
	mat.set_shader_param("noise_texture", tex)
	yield(get_tree(), "idle_frame")

	
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
	yield(get_tree(), "idle_frame")

