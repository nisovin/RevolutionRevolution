extends Node2D

const Planet = preload("res://Planet.tscn")
const PlanetIndicator = preload("res://PlanetIndicator.tscn")

var planets = []
var radius = 0

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
	for p in planets:
		var planet = p.planet
		var ind = p.indicator
		var dir = player_pos.direction_to(planet.position)
		var dist = player_pos.distance_to(planet.position)
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
			
func generate():
	var star = Planet.instance()
	star.generate(0)
	add_child(star)
	var ind = PlanetIndicator.instance()
	ind.color = star.base_color
	$Indicators.add_child(ind)
	planets.append({"planet": star, "indicator": ind})
	
	var revolve_dir = 1 if G.rng.randf() < 0.9 else -1
	
	var belt = 0
	radius = star.diameter + 200
	for i in G.rng.randi_range(4, 9):
		if i > 0 and belt == 0 and G.rng.randf() < 0.15 * i:
			print("belt!")
			belt = radius
			continue
		#print("planet")
		var pos = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * radius
		radius += G.rng.randi_range(400, 800) * G.rng.randf_range(1, (i + 2) / 2.0)
		var planet = Planet.instance()
		planet.generate(i + 1)
		add_child(planet)
		planet.position = pos
		planet.revolve_around = star
		planet.revolve_speed = G.rng.randf_range(0.5, 1.5) / G.rng.randf_range(1, i + 1) * revolve_dir
		ind = PlanetIndicator.instance()
		ind.color = planet.base_color
		$Indicators.add_child(ind)
		planets.append({"planet": planet, "indicator": ind})

	if belt == 0:
		belt = radius
	print("belt at ", belt)
