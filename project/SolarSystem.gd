extends Node2D

const Planet = preload("res://Planet.tscn")
const PlanetIndicator = preload("res://PlanetIndicator.tscn")

var planets = []

func _ready():
	generate()
	
func _process(delta):
	var x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	$icon.position += Vector2(x, y) * delta * 500
	
	var vp = get_viewport().get_size_override()
	var center = vp / 2
	var max_dim = max(vp.x, vp.y)
	var min_dim = min(vp.x, vp.y)
	var player_pos = $icon.position
	for p in planets:
		var planet = p.planet
		var ind = p.indicator
		var dir = player_pos.direction_to(planet.position)
		var pos = center + dir * vp.y / 2
		ind.position = pos
		ind.rotation = dir.angle()
		ind.visible = player_pos.distance_squared_to(planet.position) > min_dim * min_dim
			
func generate():
	var star = Planet.instance()
	star.generate(true)
	add_child(star)
	
	var revolve_dir = 1 if G.rng.randf() < 0.9 else -1
	
	var dist = star.diameter + 200
	for i in G.rng.randi_range(2, 8):
		var pos = Vector2.RIGHT.rotated(G.rng.randf_range(0, 2 * PI)) * dist
		dist += G.rng.randi_range(400, 800) * G.rng.randf_range(1, (i + 2) / 2.0)
		var planet = Planet.instance()
		planet.generate()
		add_child(planet)
		planet.position = pos
		planet.revolve_around = star
		planet.revolve_speed = G.rng.randf_range(0.5, 1.5) / G.rng.randf_range(1, i + 1) * revolve_dir
		var ind = PlanetIndicator.instance()
		ind.color = planet.base_color
		$Indicators.add_child(ind)
		planets.append({"planet": planet, "indicator": ind})
