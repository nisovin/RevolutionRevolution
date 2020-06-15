extends RigidBody2D

signal left_home
signal reached_belt
signal captured_asteroid
signal been_rejected

enum State { MENU, START, ORBITING, FREE, TRAVELING, GAME_OVER }

var state = State.MENU

var acceleration = 300
var max_speed = 500
var fire_speed = 150

var size = 8
var req_pos = null
var req_vel = null

var parent
var angle = 0
var asteroids = []

var health = 0.0
var recovering = 0
var recover_cooldown = 0
var invulnerable = true

var have_reached_belt = false
var have_captured = false
var have_been_rejected = false

func _ready():
	G.player = self
	$Planet.set_as_player()
	$Planet.base_color = Color.cyan
	$Planet.radius = size
	$Planet.generate_planet(1)
	$Camera2D.target = self
	
func speak(text, duration, target):
	$Planet.speak(text, duration, target)

func take_damage(amount, recoverable = false):
	if invulnerable: return
	health -= amount
	recover_cooldown = 5
	if recovering > 0:
		recovering *= 0.75
	if recoverable:
		recovering += amount

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
				if not have_been_rejected:
					have_been_rejected = true
					call_deferred("emit_signal", "been_rejected")
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
		size += 1
		$Planet.radius = size
		$Planet.generate_planet(1)
		$CollisionShape2D.shape.radius = size * 2
		mass = size

func reset():
	state = State.START
	set_position_and_velocity(Vector2.ZERO, Vector2.ZERO)

func set_home(home):
	parent = home
	$Camera2D.target = home

func start():
	state = State.ORBITING

func show_health_bar():
	var bar = $CanvasLayer/HealthBar
	bar.modulate = Color.transparent
	bar.visible = true
	$Tween.interpolate_property(bar, "modulate", Color.transparent, Color.white, 1.5)
	$Tween.interpolate_property(self, "health", 0.0, 100.0, 2.5, Tween.TRANS_QUAD, Tween.EASE_IN, 0.5)
	$Tween.start()
	yield(get_tree().create_timer(2.5), "timeout")
	invulnerable = false

func travel(t):
	if t:
		state = State.TRAVELING
		$Camera2D.loose = false
		var h = health + 20
		if h > 100: h = 100
		$Tween.interpolate_property(self, "health", health, h, 5, Tween.TRANS_LINEAR, Tween.EASE_IN, 1)
		$Tween.start()
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
		if recover_cooldown > 0:
			recover_cooldown -= delta
		if recovering > 0 and recover_cooldown <= 0:
			var amt = 3 * delta
			if amt > recovering:
				amt = recovering
				recovering = 0
			else:
				recovering -= amt
			health += amt
			if health > 100:
				health = 100
		$CanvasLayer/HealthBar.value = health
		

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
		applied_force = v * acceleration * mass * (2 - ((v.dot(vel_dir) + 1) / 2))
	
	_state.linear_velocity = _state.linear_velocity.clamped(max_speed)
	
	if state == State.TRAVELING:
		$CanvasLayer/SpeedLabel.text = "Speed: " + str(1000000 + G.rng.randi_range(1000, 100000)) + " xel/s"
		$CanvasLayer/PositionLabel.text = "Positon: ???"
	else:
		$CanvasLayer/SpeedLabel.text = "Speed: " + str(ceil(min(max_speed * 10, _state.linear_velocity.length()))) + " xel/s"
		$CanvasLayer/PositionLabel.text = "Position: " + str(floor(position.x / 10)) + ", " + str(floor(position.y / 10))

func cycle_color():
	if state == State.MENU:
		var h = $Planet.base_color.h
		h += G.rng.randf_range(0.03, 0.07)
		if h > 1: h -= 1
		if h < 0.33: h += 0.33
		$Planet.base_color.h = h
		$Planet.data = null
		$Planet.generate_planet(1)


func _on_Player_body_entered(body):
	if body.is_in_group("planets"):
		var base_dam = 0
		var psize = body.get_parent().radius
		if psize > size * 3:
			base_dam = 2.0
		elif psize > size * 2:
			base_dam = 1.25
		else:
			base_dam = 1.0
		if base_dam > 0:
			var vel = linear_velocity.length()
			if vel > 150:
				print(vel)
				take_damage(vel / 100 * base_dam, true)
				Audio.play("thwack")
	elif body.is_in_group("asteroids"):
		if body.size > size * 2:
			take_damage(3, true)
