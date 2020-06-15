extends Node2D

signal arrived_at_belt
signal planet_leaving
signal approached_sun

enum State { START, NORMAL, TRAVELING }

const Planet = preload("res://planets/Planet.tscn")
const PlanetIndicator = preload("res://planets/PlanetIndicator.tscn")
const Asteroid = preload("res://asteroids/Asteroid.tscn")

var state = State.START
var bodies = []
var home_planet
var radius = 0
var belt = 0
var have_entered_belt = false
var have_planet_fled = false
var have_approached_sun = false

func _process(delta):
	var vp = get_viewport().get_size_override()
	var center = vp / 2
	var max_dim = max(vp.x, vp.y)
	var min_dim = min(vp.x, vp.y)
	var max_y = vp.y / 2 - 8
	var max_x = vp.x / 2 - 8
	var player_pos = G.player.position
	for b in bodies:
		var ind = b.indicator
		var body_pos
		if b.type == "planet" or b.type == "star":
			body_pos = b.body.position
		elif b.type == "belt":
			body_pos = player_pos.normalized().rotated(PI / 50) * belt
			#body_pos = player_pos.normalized() * b.belt
		elif b.type == "exit":
			#if player_pos.length() > belt:
				body_pos = player_pos.normalized() * b.distance
			#else:
			#	body_pos = player_pos.normalized().rotated(PI / 40) * b.distance
		else:
			continue
		var dir = player_pos.direction_to(body_pos)
		var dist = player_pos.distance_to(body_pos)
		var vec = dir * max_dim
		if abs(vec.y) > max_y:
			vec.x = vec.x * max_y / vec.y * sign(vec.y)
			vec.y = max_y * sign(vec.y)
		if abs(vec.x) > max_x:
			vec.y = vec.y * max_x / vec.x * sign(vec.x)
			vec.x = max_x * sign(vec.x)
		var pos = center + vec
		ind.position = pos
		ind.set_arrow_rotation(dir.angle())
		ind.set_label_text(str(floor(dist / 10)))
		ind.visible = b.indvis and dist > min_dim
		if not have_entered_belt and b.indvis and not ind.visible and b.type == "belt":
			have_entered_belt = true
			call_deferred("emit_signal", "arrived_at_belt")
		if have_planet_fled and not have_approached_sun and b.type == "star" and dist < b.body.radius * 2 + 200:
			have_approached_sun = true
			call_deferred("emit_signal", "approached_sun")
			
		
func _physics_process(delta):
	if state == State.NORMAL and G.player.position.length_squared() > radius * radius:
		goto_new_system()

func _on_planet_leave():
	if not have_planet_fled:
		have_planet_fled = true
		call_deferred("emit_signal", "planet_leaving")

func goto_new_system():
	state = State.TRAVELING
	bodies = []
	G.player.travel(true)
	
	var start = OS.get_ticks_msec()
	
	var player_dir = G.player.position.normalized()
	print("dir ", player_dir)
	Audio.play_wormhole()
	$Background.goto_warp(player_dir)
	$Tween.interpolate_property($Planets, "modulate", Color.white, Color.transparent, 0.5)
	$Tween.interpolate_property($Asteroids, "modulate", Color.white, Color.transparent, 0.5)
	$Tween.interpolate_property($Indicators/I, "modulate", Color.white, Color.transparent, 0.5)
	$Tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	for child in $Planets.get_children():
		child.queue_free()
	for child in $Asteroids.get_children():
		child.queue_free()
	for child in $Indicators/I.get_children():
		child.queue_free()
	yield(get_tree().create_timer(1.5), "timeout")
	
	radius = 0
	belt = 0
	yield(generate(), "completed")
	
	G.player.set_position_and_velocity(-player_dir * radius * 0.8, player_dir.normalized() * G.player.max_speed)
	
	var wait = 10000 - (OS.get_ticks_msec() - start)
	if wait > 1000:
		yield(get_tree().create_timer(wait / 1000), "timeout")
	else:
		yield(get_tree().create_timer(1), "timeout")
		
	Audio.stop_wormhole()
	$Background.goto_normal()
	$Tween.interpolate_property($Planets, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.interpolate_property($Asteroids, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.interpolate_property($Indicators/I, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.start()
	
	G.player.travel(false)
	state = State.NORMAL
		
func generate(first = false):
	yield($Background.generate(), "completed")
	
	var star = Planet.instance()
	star.generate(0)
	star.modulate = Color(1.3, 1.3, 1.3)
	$Planets.add_child(star)
	var ind = PlanetIndicator.instance()
	ind.color = star.base_color
	ind.type = "star"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "star", "body": star, "indicator": ind, "indvis": !first})
	yield(get_tree(), "idle_frame")
	
	var revolve_dir = 1 if G.rng.randf() < 0.75 else -1
	
	radius = star.diameter + 200
	for i in G.rng.randi_range(6 if first else 3, 9):
		if first:
			if i == 3:
				radius += 200
				belt = radius
				radius += G.rng.randi_range(600, 1000)
				continue
		else:
			if i > 0 and belt == 0 and G.rng.randf() < 0.15 * i:
				radius += 100
				belt = radius
				radius += G.rng.randi_range(600, 1000)
				continue
		var pos = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * radius
		radius += G.rng.randi_range(500, 800) * G.rng.randf_range(1, (i + 2) / 2.0)
		var planet = Planet.instance()
		if first and i == 2:
			planet.radius = 30
			planet.base_color = Color.green
			planet.generate_planet(i + 1)
			home_planet = planet
		else:
			planet.generate(i + 1)
		$Planets.add_child(planet)
		planet.modulate = Color(1.07, 1.07, 1.07)
		planet.position = pos
		planet.revolve_around = star
		planet.revolve_speed = G.rng.randf_range(0.8, 2.0) / G.rng.randf_range(1, i + 1) * revolve_dir
		planet.connect("leaving", self, "_on_planet_leave")
		ind = PlanetIndicator.instance()
		ind.color = planet.base_color
		$Indicators/I.add_child(ind)
		bodies.append({"type": "planet", "body": planet, "indicator": ind, "indvis": !first})
		yield(get_tree(), "idle_frame")

	if belt == 0:
		belt = radius
		radius += G.rng.randi_range(600, 1000)
		
	var phi = ((Vector2.RIGHT * belt) + (Vector2.DOWN * 50)).angle()
	var count = ceil(2 * PI / phi) * 2
	var theta = 0
	for i in count:
		theta += G.rng.randf_range(phi / 2, phi)
		if theta > 2 * PI:
			break
		var ast = Asteroid.instance()
		ast.position = Vector2.RIGHT.rotated(theta) * G.rng.randf_range(belt - 200, belt + 200)
		ast.revolve_dir = revolve_dir
		ast.generate()
		$Asteroids.add_child(ast)
	ind = PlanetIndicator.instance()
	ind.color = Color.lightgray
	ind.type = "asteroids"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "belt", "belt": belt, "indicator": ind, "indvis": !first})
	yield(get_tree(), "idle_frame")

	var r = star.diameter + 300
	for i in radius / 50:
		r += G.rng.randi_range(50, 125)
		var ast = Asteroid.instance()
		ast.position = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * r
		ast.revolve_dir = revolve_dir
		ast.generate()
		$Asteroids.add_child(ast)
	yield(get_tree(), "idle_frame")

	radius += 1500
	ind = PlanetIndicator.instance()
	ind.color = Color.magenta
	ind.type = "exit"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "exit", "distance": radius, "indicator": ind, "indvis": !first})
	
	if state == State.START:
		state = State.NORMAL
