extends RigidBody2D

enum State { START, ORBITING, FREE, TRAVELING }

var state = State.ORBITING

var acceleration = 200
var max_speed = 500

var size = 8
var req_pos = null
var req_vel = null

var parent
var angle = 0
var asteroids = []

func _ready():
	$Planet.is_player = true
	$Planet.base_color = Color.cyan
	$Planet.radius = size
	mass = 2
	$Planet.remove_body()
	$Planet.generate_planet(1)
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
	if t:
		state = State.TRAVELING
	else:
		state = State.FREE
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

func _process(delta):
	if state == State.START or state == State.ORBITING:
		if parent != null:
			$Camera2D.global_position = parent.global_position
	elif $Camera2D.position != Vector2.ZERO:
		$Camera2D.position = $Camera2D.position.linear_interpolate(Vector2.ZERO, 1 * delta)
		if $Camera2D.position.length_squared() < 1:
			$Camera2D.position = Vector2.ZERO
			set_process(false)
			print("done")

func _physics_process(delta):
	if state == State.START or state == State.ORBITING:
		if parent == null: return
		angle += PI / 4 * delta
		position = parent.position + Vector2.RIGHT.rotated(angle) * 130

func _integrate_forces(_state):
	if state == State.START: return
	
	if req_pos != null:
		_state.transform.origin = req_pos
		req_pos = null
	if req_vel != null:
		_state.linear_velocity = req_vel
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
		if state == State.ORBITING:
			state = State.FREE
			set_deferred("mode", RigidBody2D.MODE_CHARACTER)
			print("FREE!")
			return
		var vel_dir = _state.linear_velocity.normalized()
		applied_force = v * acceleration * (2 - ((v.dot(vel_dir) + 1) / 2))
	
	_state.linear_velocity = _state.linear_velocity.clamped(max_speed)
	
	if state == State.TRAVELING:
		$CanvasLayer/SpeedLabel.text = "Speed: " + str(1000000 + G.rng.randi_range(1000, 100000)) + " xel/s"
		$CanvasLayer/PositionLabel.text = "Positon: ???"
	else:
		$CanvasLayer/SpeedLabel.text = "Speed: " + str(ceil(min(max_speed * 10, _state.linear_velocity.length()))) + " xel/s"
		$CanvasLayer/PositionLabel.text = "Position: " + str(floor(position.x / 10)) + ", " + str(floor(position.y / 10))
