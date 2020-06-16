extends Node2D

enum State { REVOLVING, LEAVING }

signal leaving

var state = State.REVOLVING
var revolve_around = null
var revolve_speed = 1
var captured_by = null
var leave_vector = null

var health = 20
var radius = 0
var diameter = 0
var base_color = Color.white
var voice = 1
var is_player = false
var data = null

#func _ready():
#	radius = 20
#	base_color = Color.blue
#	generate_planet(1)
#	$Sprite.position += Vector2(100, 100)

func _process(delta):
	if state == State.REVOLVING and revolve_around != null:
		var v = position - revolve_around.position
		v = v.rotated(deg2rad(revolve_speed) * delta)
		position = revolve_around.position + v
	elif state == State.LEAVING:
		var dir = position.normalized()
		position += dir * 300 * delta

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
	if is_player:
		Audio.play("playervoice")
	else:
		Audio.play("planetvoice" + str(voice))

func take_damage(amount):
	if state != State.REVOLVING: return
	health -= amount
	if health > 0:
		speak(G.rand_dialog("take_damage"), 1.5, G.player.position)
	else:
		speak(G.rand_dialog("fed_up"), 2.0, G.player.position)
		state = State.LEAVING
		emit_signal("leaving")
		

func generate(index):
	if index == 0:
		radius = G.rng.randi_range(150, 300)
		base_color = Color.from_hsv(G.rng.randf_range(0.05, 0.17), 1.0, G.rng.randf_range(0.8, 1.0))
	else:
		radius = G.rng.randi_range(15, 30 + index * 5)
		base_color = Color.from_hsv(G.rng.randf_range(0.3, 0.95), G.rng.randf_range(0.8, 1.0), G.rng.randf_range(0.5, 0.9))
	generate_planet(index)

func generate_planet(index):
	if data == null:
		data = {}
		data.color_point_count = min(G.rng.randi_range(2, radius / 10), 15)
		if is_player:
			data.color_point_count = G.rng.randi_range(4, 7)
		data.color_points_colors = []
		for i in data.color_point_count:
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
			data.color_points_colors.append(c)
		data.noise_seed = G.rng.randi()
		data.noise_lacunarity = G.rng.randf_range(2.0, 5.0)
		data.noise_period = G.rng.randf_range(20, 100)
		data.noise_persistence = G.rng.randf_range(0.25, 0.75)
		data.cloud_color = Color.from_hsv(G.rng.randf_range(0.3, 0.95), G.rng.randf_range(0.3, 0.7), G.rng.randf_range(0.5, 0.9))
		if is_player:
			data.cloud_color.s = G.rng.randf_range(0.1, 0.3)
		data.cloud_speed = G.rng.randf_range(0.3, 1.0) * (1 if G.rng.randf() < 0.5 else -1)
		data.cloud_density = G.rng.randf_range(0.5, 0.8)
		data.rotated = G.rng.randf() < 0.2
		
	diameter = radius * 2 + 1
	if not is_player:
		if index == 0:
			voice = 1
		else:
			voice = G.rng.randi_range(2, 9)
		if index > 0:
			$StaticBody2D/CollisionShape2D.shape.radius = radius * 2
		
	var rad_sq = (radius + 0.0) * (radius + 0.0)
	var center = Vector2(radius + 0.5, radius + 0.5)
	
	var color_points = []
	for i in data.color_point_count:
		var c = data.color_points_colors[i]
		var p = center + Vector2(radius, radius).rotated(G.rng.randf_range(0, 2 * PI))
		color_points.append({"color": c, "point": p})
	
	var image = Image.new()
	image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	image.lock()
	for x in diameter:
		for y in diameter:
			var v = Vector2(x, y)
			if x < radius: v.x += 1
			if y < radius: v.y += 1
			if v.distance_squared_to(center) <= rad_sq:
				var color = base_color
				for p in color_points:
					var pct = v.distance_squared_to(p.point) / (diameter*diameter) / 1.5
					var c = p.color
					color = color.blend(Color(c.r, c.g, c.b, pct))
				image.set_pixel(x, y, color)
			else:
				image.set_pixel(x, y, Color.transparent)
	image.unlock()
	
	$Sprite.texture = ImageTexture.new()
	$Sprite.texture.create_from_image(image, 0)
	
	if index == 0:
		$Sprite.material = null
		$NameLabel.text = "Sun"
		return
	
	var noise = OpenSimplexNoise.new()
	noise.seed = data.noise_seed
	noise.lacunarity = data.noise_lacunarity
	noise.period = data.noise_period
	noise.persistence = data.noise_persistence
	var noise_img = noise.get_seamless_image(diameter * 2)
	var noise_tex = ImageTexture.new()
	noise_tex.create_from_image(noise_img, 0)
	
	var mat = $Sprite.material as ShaderMaterial
	mat.set_shader_param("color", data.cloud_color)
	mat.set_shader_param("speed", data.cloud_speed)
	mat.set_shader_param("density", data.cloud_density)
	mat.set_shader_param("noise_texture", noise_tex)

	if data.rotated:
		$Sprite.rotation = PI / 2
	else:
		$Sprite.rotation = 0

	$NameLabel.text = G.rand_planet_name()
	$NameLabel.set("custom_colors/font_color", base_color.lightened(0.6))
	$NameLabel.set("custom_colors/font_outline_modulate", base_color.darkened(0.6))
	$NameLabel.rect_position.y -= radius * 2 + 20
	
	$Dialog/Text.set("custom_colors/font_color", base_color.lightened(0.8))
	$Dialog/Text.set("custom_colors/font_color_shadow", base_color.darkened(0.6))
