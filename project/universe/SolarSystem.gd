extends Node2D

enum State { NORMAL, TRAVELING }

const Planet = preload("res://planets/Planet.tscn")
const PlanetIndicator = preload("res://planets/PlanetIndicator.tscn")
const Asteroid = preload("res://asteroids/Asteroid.tscn")

var state = State.NORMAL
var bodies = []
var radius = 0
var belt = 0

func _ready():
	generate()
	
func _process(delta):
	var vp = get_viewport().get_size_override()
	var center = vp / 2
	var max_dim = max(vp.x, vp.y)
	var min_dim = min(vp.x, vp.y)
	var max_y = vp.y / 2 - 4
	var max_x = vp.x / 2 - 4
	var player_pos = $Player.position
	for b in bodies:
		var ind = b.indicator
		var body_pos
		if b.type == "planet" or b.type == "star":
			body_pos = b.body.position
		elif b.type == "belt":
			body_pos = player_pos.normalized() * b.belt
		elif b.type == "exit":
			if player_pos.length() > belt:
				body_pos = player_pos.normalized() * b.distance
			else:
				body_pos = player_pos.normalized().rotated(PI / 40) * b.distance
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
		ind.visible = dist > min_dim
		
func _physics_process(delta):
	
	if $Player.position.length_squared() > radius * radius:
	#if Input.is_action_just_pressed("ui_accept"):
		if state == State.NORMAL:
			goto_new_system()
		
func goto_new_system():
	state = State.TRAVELING
	bodies = []
	$Player.travel(true)
	
	var start = OS.get_ticks_msec()
	
	var player_dir = $Player.position.normalized()
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
	
	$Player.set_position_and_velocity(-player_dir * radius * 0.8, player_dir.normalized() * $Player.max_speed)
	
	var wait = 10000 - (OS.get_ticks_msec() - start)
	if wait > 0:
		yield(get_tree().create_timer(wait / 1000), "timeout")
	$Background.goto_normal()
	$Tween.interpolate_property($Planets, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.interpolate_property($Asteroids, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.interpolate_property($Indicators/I, "modulate", Color.transparent, Color.white, 0.5)
	$Tween.start()
	
	$Player.travel(false)
	state = State.NORMAL
		
func generate():
	yield($Background.generate(), "completed")
	
	var star = Planet.instance()
	star.generate(0)
	$Planets.add_child(star)
	var ind = PlanetIndicator.instance()
	ind.color = star.base_color
	ind.type = "star"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "star", "body": star, "indicator": ind})
	yield(get_tree(), "idle_frame")
	
	var revolve_dir = 1 if G.rng.randf() < 0.9 else -1
	
	radius = star.diameter + 200
	for i in G.rng.randi_range(4, 9):
		if i > 0 and belt == 0 and G.rng.randf() < 0.15 * i:
			print("belt!")
			belt = radius
			radius += G.rng.randi_range(600, 1000)
			continue
		#print("planet")
		var pos = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * radius
		radius += G.rng.randi_range(400, 800) * G.rng.randf_range(1, (i + 2) / 2.0)
		var planet = Planet.instance()
		planet.generate(i + 1)
		$Planets.add_child(planet)
		planet.position = pos
		planet.revolve_around = star
		planet.revolve_speed = G.rng.randf_range(0.5, 1.5) / G.rng.randf_range(1, i + 1) * revolve_dir
		ind = PlanetIndicator.instance()
		ind.color = planet.base_color
		$Indicators/I.add_child(ind)
		bodies.append({"type": "planet", "body": planet, "indicator": ind})
		yield(get_tree(), "idle_frame")

	if belt == 0:
		belt = radius
		
	var phi = ((Vector2.RIGHT * belt) + (Vector2.DOWN * 50)).angle()
	var count = ceil(2 * PI / phi)
	var theta = 0
	for i in count:
		theta += G.rng.randf_range(phi / 2, phi)
		if theta > 2 * PI:
			break
		var ast = Asteroid.instance()
		ast.position = Vector2.RIGHT.rotated(theta) * G.rng.randf_range(belt - 200, belt + 200)
		ast.generate()
		$Asteroids.add_child(ast)
	ind = PlanetIndicator.instance()
	ind.color = Color.lightgray
	ind.type = "asteroids"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "belt", "belt": belt, "indicator": ind})
	yield(get_tree(), "idle_frame")

	var r = star.diameter + 300
	for i in radius / 50:
		r += G.rng.randi_range(50, 125)
		var ast = Asteroid.instance()
		ast.position = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * r
		ast.generate()
		$Asteroids.add_child(ast)
	yield(get_tree(), "idle_frame")

	radius += 1000
	ind = PlanetIndicator.instance()
	ind.color = Color.magenta
	ind.type = "exit"
	$Indicators/I.add_child(ind)
	bodies.append({"type": "exit", "distance": radius, "indicator": ind})