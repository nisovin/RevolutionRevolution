extends RigidBody2D

signal left_home
signal reached_belt
signal captured_asteroid

enum State { MENU, START, ORBITING, FREE, TRAVELING }

var state = State.MENU

var acceleration = 400
var max_speed = 500
var fire_speed = 150

var size = 8
var req_pos = null
var req_vel = null

var parent
var angle = 0
var asteroids = []
var have_reached_belt = false
var have_captured = false

func _ready():
	G.player = self
	$Planet.set_as_player()
	$Planet.base_color = Color.cyan
	$Planet.radius = size
	$Planet.generate_planet(1)
	$Camera2D.target = self
	
func speak(text, duration, target):
	$Planet.speak(text, duration, target)

func _unhandled_input(event):
	if state != State.FREE: return
	if event.is_action_pressed("capture"):
		speak(G.rand_dialog("call_out"), 1.0, position + Vector2.DOWN * 100)
		for body in $ShoutRange.get_overlapping_bodies():
			if body.is_in_group("asteroids"):
				if body.size < size * .75 and asteroids.size() < 15:
					var cap = body.capture(self)
					if cap:
						asteroids.append(body)
						if not have_captured:
							have_captured = true
							call_deferred("emit_signal", "captured_asteroid")
			elif body.is_in_group("planets"):
				yield(get_tree().create_timer(1), "timeout")
				body.get_parent().speak(G.rand_dialog("rejection"), 1.5, position)
		update_asteroid_label()
	elif event.is_action_pressed("fire"):
		var target = get_global_mouse_position()
		var to_fire = null
		var nearest = 0
		for a in asteroids:
			var d = a.global_position.distance_squared_to(global_position)
			if nearest == 0 or d < nearest:
				nearest = d
				to_fire = a
		if to_fire != null:
			to_fire.fire(to_fire.global_position.direction_to(target) * fire_speed)
			Audio.play("launch", 0.5)
			asteroids.erase(to_fire)
			update_asteroid_label()
	elif event.is_action_pressed("ui_page_up"):
		$Planet.radius += 1
		$Planet.generate_planet(1)
		$CollisionShape2D.shape.radius = $Planet.radius * 2

func reset():
	state = State.START
	set_position_and_velocity(Vector2.ZERO, Vector2.ZERO)

func set_home(home):
	parent = home
	$Camera2D.target = home

func start():
	state = State.ORBITING

func travel(t):
	if t:
		state = State.TRAVELING
		$Camera2D.loose = false
	else:
		state = State.FREE
		$Camera2D.loose = true
	asteroids = []
	update_asteroid_label()

func update_asteroid_label():
	if asteroids.size() > 0:
		$CanvasLayer/AsteroidLabel.visible = true
	$CanvasLayer/AsteroidLabel.text = "Followers: " + str(asteroids.size())

func set_position_and_velocity(pos, vel):
	sleeping = true
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	req_pos = pos
	req_vel = vel
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	sleeping = false

func _process(delta):
	if state == State.MENU:
		position += Vector2.DOWN * 50 * delta
	else:
		set_process(false)

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
			$Camera2D.target = self
			$Camera2D.loose = true
			set_deferred("mode", RigidBody2D.MODE_CHARACTER)
			call_deferred("emit_signal", "left_home")
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

func _on_Player_input_event(viewport, event, shape_idx):
	if state == State.MENU and event.is_action_pressed("move"):
		var h = $Planet.base_color.h
		h += G.rng.randf_range(0.03, 0.07)
		if h > 1: h -= 1
		if h < 0.3: h += 0.3
		$Planet.base_color.h = h
		$Planet.generate_planet(1)
