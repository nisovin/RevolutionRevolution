extends RigidBody2D

var acceleration = 200
var max_speed = 400

var size = 8
var traveling = false
var req_pos = null
var req_vel = null

var asteroids = []

func _ready():
	$Planet.is_player = true
	$Planet.base_color = Color.cyan
	$Planet.radius = size
	mass = 2
	$Planet.remove_body()
	$Planet.generate_planet(1)
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = $Planet.radius * 2
	$Planet/Label.hide()
	

func _unhandled_input(event):
	if event.is_action_pressed("capture"):
		for body in $ShoutRange.get_overlapping_bodies():
			if body.is_in_group("asteroids"):
				if body.size < size * .75:
					var cap = body.capture(self)
					if cap:
						asteroids.append(body)
		$CanvasLayer/AsteroidLabel.text = "Asteroids: " + str(asteroids.size())
	elif event.is_action_pressed("fire"):
		var target = get_global_mouse_position()
		var to_fire = null
		var farthest = 0
		for a in asteroids:
			var d = a.position.distance_squared_to(target)
			if farthest == 0 or d > farthest:
				farthest = d
				to_fire = a
		if to_fire != null:
			to_fire.fire(to_fire.position.direction_to(target))
			asteroids.erase(to_fire)
			$CanvasLayer/AsteroidLabel.text = "Asteroids: " + str(asteroids.size())
	elif event.is_action_pressed("ui_page_up"):
		$Planet.radius += 1
		$Planet.generate_planet(1)
		$CollisionShape2D.shape.radius = $Planet.radius * 2

func travel(t):
	traveling = t
	asteroids = []
	$CanvasLayer/AsteroidLabel.text = "Asteroids: " + str(asteroids.size())

func set_position_and_velocity(pos, vel):
	sleeping = true
	print('b ',position)
	print('t ', pos)
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	req_pos = pos
	req_vel = vel
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	sleeping = false
	print('a ',position)

func _integrate_forces(state):
	if req_pos != null:
		state.transform.origin = req_pos
		req_pos = null
	if req_vel != null:
		state.linear_velocity = req_vel
		req_vel = null
	
	var v = Vector2.ZERO
	if Input.is_action_pressed("move"):
		v = position.direction_to(get_global_mouse_position())
	else:
		var x = Input.get_action_strength("right") - Input.get_action_strength("left")
		var y = Input.get_action_strength("down") - Input.get_action_strength("up")
		if x != 0 or y != 0:
			v = Vector2(x, y).normalized()
	if v == Vector2.ZERO:
		applied_force = -position.normalized() * acceleration * 0.01
	else:
		var vel_dir = state.linear_velocity.normalized()
		applied_force = v * acceleration * (2 - ((v.dot(vel_dir) + 1) / 2))
	
	state.linear_velocity = state.linear_velocity.clamped(max_speed)
	
	if traveling:
		$CanvasLayer/SpeedLabel.text = "Speed: " + str(1000000 + G.rng.randi_range(1000, 100000)) + " xel/s"
		$CanvasLayer/PositionLabel.text = "Positon: ???"
	else:
		$CanvasLayer/SpeedLabel.text = "Speed: " + str(ceil(min(max_speed, state.linear_velocity.length()))) + " xel/s"
		$CanvasLayer/PositionLabel.text = "Position: " + str(floor(position.x / 10)) + ", " + str(floor(position.y / 10))
