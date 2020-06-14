extends Node2D

var revolve_around = null
var revolve_speed = 1
var captured_by = null

var radius = 0
var diameter = 0
var base_color = Color.white
var is_player = false

var prefixes = ["Mer", "Ven", "Mar", "Jup", "Sat", "Ur", "Nep", "Plut", "Ark", "Orb", "Dim", "Gal", "Jan", "Har", "Amat", "Tad", "Mez", "Hyp", "Arb", "Mad", "Yan", "Sis"]
var infixes = ["a", "e", "i", "o", "u", "ae", "io", "ecu", "au", "ea", "eu", "ia", "ai", "ei", "ou", "oo", "ue", "eo"]
var suffixes = ["ry", "nus", "ter", "turn", "nus", "tune", "to", "s", "th", "ch", "x", "ve", "ron", "rion", "kas", "tar", "dium", "leo", "sen", "gon", "trios", "tia", "nea", "tias", "far", "cho", "sh", "dra", "lay", "les", "los", "sama", "dono", "san", "chan", "kun"]

func _process(delta):
	if captured_by != null:
		pass
	elif revolve_around != null:
		var v = position - revolve_around.position
		v = v.rotated(deg2rad(revolve_speed) * delta)
		position = revolve_around.position + v

func set_as_player():
	is_player = true
	$StaticBody2D.queue_free()
	$NameLabel.hide()

func speak(text, duration, target):
	$Dialog/Text.text = ""
	$Dialog/Text.rect_size = Vector2.ZERO
	yield(get_tree(), "idle_frame")
	$Dialog/Text.text = text
	yield(get_tree(), "idle_frame")
	var pos = global_position.direction_to(target) * (diameter + 20)
	$Dialog/Text.rect_position = pos - ($Dialog/Text.rect_size / 2)
	$Tween.stop_all()
	$Tween.interpolate_property($Dialog, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.interpolate_property($Dialog, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, duration + 0.5)
	$Tween.start()

func generate(index):
	if index == 0:
		radius = G.rng.randi_range(80, 150)
		base_color = Color.from_hsv(G.rng.randf_range(0.05, 0.17), 1.0, G.rng.randf_range(0.8, 1.0))
	else:
		radius = G.rng.randi_range(15, 30 + index * 5)
		base_color = Color.from_hsv(G.rng.randf_range(0.3, 0.95), G.rng.randf_range(0.8, 1.0), G.rng.randf_range(0.5, 0.9))
	generate_planet(index)
	
func generate_planet(index):
	diameter = radius * 2 + 1
	if not is_player:
		if index > 0:
			$StaticBody2D/CollisionShape2D.shape.radius = radius * 2
		
	var rad_sq = radius * radius
	var center = Vector2(radius, radius)
	
	var color_points = []
	for i in G.rng.randi_range(2, radius / 10):
		var c
		if G.rng.randf() < .5:
			c = base_color.darkened(G.rng.randf_range(0.1, 0.2))
		else:
			c = base_color.lightened(G.rng.randf_range(0.1, 0.2))
		var h = c.h
		if index == 0:
			h += G.rng.randf_range(-0.04, 0.04)
			if h > 0.17: h = 0.17
		else:
			h += G.rng.randf_range(-0.2, 0.2)
		if h < 0: h += 1.0
		elif h > 1: h -= 1.0
		c.h = h
		var p = center + Vector2(radius, radius).rotated(G.rng.randf_range(0, 2 * PI))
		color_points.append({"color": c, "point": p})
	
	var image = Image.new()
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
	
	if index == 0:
		$Sprite.material = null
		$NameLabel.text = "Sun"
		return
	
	var noise = OpenSimplexNoise.new()
	noise.seed = G.rng.randi()
	noise.lacunarity = G.rng.randf_range(2.0, 4.0)
	#noise.octaves = G.rng.randi_range(2, 5)
	noise.period = G.rng.randf_range(20, 100)
	noise.persistence = G.rng.randf_range(0.25, 0.75)
	var noise_img = noise.get_seamless_image(diameter * 2)
	var noise_tex = ImageTexture.new()
	noise_tex.create_from_image(noise_img, 0)

	var over_color = Color()
	over_color = over_color.from_hsv(G.rng.randf_range(0.3, 0.95), G.rng.randf_range(0.3, 0.7), G.rng.randf_range(0.5, 0.9))
	if is_player:
		over_color.s = G.rng.randf_range(0.1, 0.3)

#	rect = ColorRect.new()
#	rect.rect_size = Vector2(50, 20)
#	rect.rect_position = Vector2(60, 0)
#	rect.color = over_color
#	add_child(rect)
	
	var mat = $Sprite.material as ShaderMaterial
	mat.set_shader_param("color", over_color)
	mat.set_shader_param("speed", G.rng.randf_range(0.3, 1.0) * 1 if G.rng.randf() < 0.5 else -1)
	mat.set_shader_param("density", G.rng.randf_range(0.3, 0.6) - 0.1 if is_player else 0)
	mat.set_shader_param("noise_texture", noise_tex)

	if G.rng.randf() < 0.2:
		$Sprite.rotation = PI / 2
	else:
		$Sprite.rotation = 0

	$NameLabel.text = prefixes[G.rng.randi_range(0, prefixes.size() - 1)] + infixes[G.rng.randi_range(0, infixes.size() - 1)] + suffixes[G.rng.randi_range(0, suffixes.size() - 1)]
	$NameLabel.set("custom_colors/font_color", base_color.lightened(0.6))
	$NameLabel.set("custom_colors/font_outline_modulate", base_color.darkened(0.6))
	$NameLabel.rect_position.y -= radius * 2 + 20
	
	$Dialog/Text.set("custom_colors/font_color", base_color.lightened(0.8))
	$Dialog/Text.set("custom_colors/font_color_shadow", base_color.darkened(0.4))
