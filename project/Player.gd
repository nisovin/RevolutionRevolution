extends RigidBody2D

var acceleration = 200
var max_speed = 400

func _ready():
	$Planet.is_player = true
	$Planet.base_color = Color.cyan
	$Planet.radius = 6
	$Planet.remove_body()
	$Planet.generate_planet(1)
	$CollisionShape2D.shape = CircleShape2D.new()
	$CollisionShape2D.shape.radius = $Planet.radius * 2
	$Planet/Label.hide()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		$Planet.radius += 1
		$Planet.generate_planet(1)
		$CollisionShape2D.shape.radius = $Planet.radius * 2

func _integrate_forces(state):
	var v = Vector2.ZERO
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		v = position.direction_to(get_global_mouse_position())
	else:
		var x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		if x != 0 or y != 0:
			v = Vector2(x, y).normalized()
	if v == Vector2.ZERO:
		applied_force = -position.normalized() * acceleration * 0.01
	else:
		var vel_dir = state.linear_velocity.normalized()
		applied_force = v * acceleration * (2 - ((v.dot(vel_dir) + 1) / 2))
	
	state.linear_velocity = state.linear_velocity.clamped(max_speed)
	$CanvasLayer/SpeedLabel.text = "Speed: " + str(ceil(min(max_speed, state.linear_velocity.length()))) + " xel/s"
	$CanvasLayer/PositionLabel.text = "Position: " + str(floor(position.x / 10)) + ", " + str(floor(position.y / 10))
