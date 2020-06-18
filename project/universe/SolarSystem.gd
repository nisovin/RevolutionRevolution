extends Node2D

signal arrived_at_belt
signal planet_defeated
signal approached_sun
signal traveled

enum State { START, NORMAL, TRAVELING }

const Planet = preload("res://planets/Planet.tscn")
const PlanetIndicator = preload("res://planets/PlanetIndicator.tscn")
const Asteroid = preload("res://asteroids/Asteroid.tscn")
const Comet = preload("res://universe/Comet.tscn")
const SolarFlare = preload("res://universe/SolarFlare.tscn")

var state = State.START
var bodies = []
var home_planet
var radius = 0
var belt = 0
var have_entered_belt = false
var have_planet_fled = false
var have_approached_sun = false
var have_traveled = false
var prevent_leave_cooldown = 0
var prevent_leave_speak_cooldown = 0

var last_attacked_planet = 0
var star_attack_cooldown = 0

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
		if have_approached_sun:
			goto_new_system()
		else:
			if prevent_leave_cooldown <= 0:
				G.player.set_position_and_velocity(null, G.player.position.normalized() * -2500)
				prevent_leave_cooldown = 2
			else:
				prevent_leave_cooldown -= delta
			if prevent_leave_speak_cooldown <= 0:
				prevent_leave_speak_cooldown = 8
				G.player.speak("The sun won't let me\nleave the system.", 3, Vector2.ZERO)
			else:
				prevent_leave_speak_cooldown -= delta

func _on_planet_attacked():
	last_attacked_planet = OS.get_ticks_msec()

func _on_planet_defeated():
	if not have_planet_fled:
		have_planet_fled = true
		call_deferred("emit_signal", "planet_defeated")
	if not G.first_system:
		var comet = Comet.instance()
		$Spawns.add_child(comet)

func can_pause():
	return state == State.NORMAL

func goto_new_system():
	state = State.TRAVELING
	bodies = []
	G.player.travel(true)
	
	var start = OS.get_ticks_msec()
	
	var player_dir = G.player.position.normalized()
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
	for child in $Spawns.get_children():
		child.queue_free()
	for child in $Indicators/I.get_children():
		child.queue_free()
	yield(get_tree().create_timer(1.5), "timeout")
	G.first_system = false
	
	radius = 0
	belt = 0
	last_attacked_planet = 0
	yield(generate(), "completed")
	
	G.player.set_position_and_velocity(-player_dir * radius * 0.8, player_dir.normalized() * G.player.max_speed)
	
	var wait = 7000 - (OS.get_ticks_msec() - start)
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
	
	yield(get_tree().create_timer(5, false), "timeout")
	$Indicators/SystemName.text = G.rand_system_name()
	$Tween.interpolate_property($Indicators/SystemName, "modulate", Color.transparent, Color.white, 1)
	$Tween.interpolate_property($Indicators/SystemName, "modulate", Color.white, Color.transparent, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 4)
	$Tween.start()
	
	if not have_traveled:
		yield(get_tree().create_timer(2, false), "timeout")
		emit_signal("traveled")
		
func generate():
	yield($Background.generate(), "completed")
	
	# system revolution direction
	var revolve_dir = 1 if G.rng.randf() < 0.75 else -1
	
	# generate star
	var star = Planet.instance()
	star.generate_star()
	star.modulate = Color(1.25, 1.2, 1.15)
	$Planets.add_child(star)
	var ind = PlanetIndicator.instance()
	ind.color = star.base_color
	ind.type = "star"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "star", "body": star, "indicator": ind, "indvis": !G.first_system})
	yield(get_tree(), "idle_frame")
	radius = star.diameter + 400
	
	# generate planets
	for i in G.rng.randi_range(6 if G.first_system else 3, 9):
		# decide on asteroid belt
		if G.first_system:
			if i == 3: # force asteroid belt at position #3
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
		# add planet
		var pos = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * radius
		radius += G.rng.randi_range(500, 800) * G.rng.randf_range(1, (i + 2) / 2.0)
		var planet = Planet.instance()
		if G.first_system and i == 2: # home planet at position #2
			planet.radius = 30
			planet.base_color = Color.green
			planet.generate("planet", i + 1)
			home_planet = planet
		else:
			planet.generate_planet(i + 1)
			if not G.first_system and i == 0:
				home_planet = planet
		planet.modulate = Color(1.05, 1.05, 1.05)
		planet.position = pos
		planet.revolve_around = star
		planet.revolve_speed = G.rng.randf_range(1, 2.5) / G.rng.randf_range(1, i + 1) * revolve_dir
		planet.connect("defeated", self, "_on_planet_defeated")
		planet.connect("attacked", self, "_on_planet_attacked")
		$Planets.add_child(planet)
		ind = PlanetIndicator.instance()
		ind.color = planet.base_color
		$Indicators/I.add_child(ind)
		bodies.append({"type": "planet", "body": planet, "indicator": ind, "indvis": !G.first_system})
		yield(get_tree(), "idle_frame")
		# add moons
		if home_planet != planet:
			var orbit = planet.moon_radius + G.rng.randf_range(0, planet.radius)
			var moon_count = min(3, G.rng.randi_range(1, planet.radius / 15))
			if G.first_system:
				moon_count = 1
			for m in moon_count:
				var moon = Planet.instance()
				moon.generate_moon(planet.radius / 3)
				moon.position = planet.position + Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * orbit
				moon.revolve_around = planet
				moon.revolve_speed = G.rng.randf_range(30, 60) * revolve_dir
				orbit += planet.radius + moon.radius * 2 + G.rng.randf_range(0, planet.radius)
				$Planets.add_child(moon)
				planet.moons.append(moon)
				

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
	bodies.append({"type": "belt", "belt": belt, "indicator": ind, "indvis": !G.first_system})
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
	bodies.append({"type": "exit", "distance": radius, "indicator": ind, "indvis": !G.first_system})
		
	if state == State.START:
		state = State.NORMAL

func _on_Timer_timeout():
	if G.first_system: return
	if star_attack_cooldown > 0:
		star_attack_cooldown -= $Timer.wait_time
	if star_attack_cooldown > 0: return
	if last_attacked_planet < OS.get_ticks_msec() - 15000: return
	var flare = SolarFlare.instance()
	flare.fire(G.player.position.normalized() * 400)
	$Spawns.add_child(flare)
	Audio.play("sunattack", 0.5)
	star_attack_cooldown = 8
