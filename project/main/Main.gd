extends Node

const SolarSystem = preload("res://universe/SolarSystem.tscn")

const skip_start = false

func _ready():
	$Background.fast = true
	yield($Background.generate(), "completed")
	$Tween.interpolate_property($Overlay/ColorRect, "color", Color.black, Color(0, 0, 0, 0), 1.0)
	$Tween.start()
	$Overlay/VBoxContainer/PlayerName.grab_focus()

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_F11:
		OS.window_fullscreen = not OS.window_fullscreen

func start():
	G.player_name = $Overlay/VBoxContainer/PlayerName.text
	if G.player_name.strip_edges() == "":
		G.player_name = "Moon"
	$Tween.interpolate_property($Overlay/ColorRect, "color", Color(0, 0, 0, 0), Color.black, 1.0)
	$Tween.start()
	yield(get_tree().create_timer(1.0), "timeout")
	$Overlay/MousePointer.queue_free()
	$Overlay/VBoxContainer.queue_free()
	$Background.queue_free()
	
	G.player.reset()
	yield(get_tree().create_timer(0.2), "timeout")
	
	var system = SolarSystem.instance()
	add_child(system)
	yield(get_tree().create_timer(0.2), "timeout")
	yield(system.generate(true), "completed")
	G.player.set_home(system.home_planet)
	
	$Tween.interpolate_property($Overlay/ColorRect, "color", Color.black, Color(0, 0, 0, 0), 1.0)
	$Tween.start()
	yield(get_tree().create_timer(1.0), "timeout")
	$Overlay.queue_free()
	
	var player = G.player
	var parent = player.parent
	
	player.connect("left_home", self, "_on_left_home")
	player.connect("captured_asteroid", self, "_on_captured")
	system.connect("arrived_at_belt", self, "_on_enter_belt")
	player.connect("been_rejected", self, "_on_rejection")
	system.connect("planet_leaving", self, "_on_planet_leave")
	system.connect("approached_sun", self, "_on_approached_sun")
	
	if skip_start:
		player.start()
		for body in $SolarSystem.bodies:
			body.indvis = true
		return
		
	show_hint("Press F11 to toggle fullscreen", 3)
		
	yield(get_tree().create_timer(2), "timeout")
	parent.speak(G.rand_dialog("open_greeting"), 3, player.position)
	yield(get_tree().create_timer(3.5), "timeout")
	player.speak(G.rand_dialog("open_dejected"), 4, parent.position)
	yield(get_tree().create_timer(4.5), "timeout")
	parent.speak(G.rand_dialog("open_chastise"), 3, player.position)
	yield(get_tree().create_timer(3.5), "timeout")
	player.speak(G.rand_dialog("open_rebel"), 2, parent.position)
	yield(get_tree().create_timer(3), "timeout")
	show_hint("Hold left click to move", 3)
	player.start()

func show_hint(text, duration, tint = Color.white):
	$GUI/HintLabel.modulate = Color.transparent
	$GUI/HintLabel.text = text
	$Tween.stop_all()
	$Tween.interpolate_property($GUI/HintLabel, "modulate", Color.transparent, tint, 1.0)
	$Tween.interpolate_property($GUI/HintLabel, "modulate", tint, Color.transparent, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, duration + 1)
	$Tween.start()

func _on_left_home():
	Audio.play("depart", 0.3)
	G.player.speak(G.rand_dialog("open_depart"), 3, G.player.parent.position)
	yield(get_tree().create_timer(5), "timeout")
	show_hint("Follow the arrow to the asteroid belt", 3)
	for body in $SolarSystem.bodies:
		if body.type == "belt":
			body.indvis = true
	G.player.show_health_bar()

func _on_enter_belt():
	yield(get_tree().create_timer(1), "timeout")
	show_hint("Press space bar to recruit", 3)

func _on_captured():
	yield(get_tree().create_timer(2), "timeout")
	show_hint("Go try to recruit a planet", 3)
	$SolarSystem.bodies[5].indvis = true
	
func _on_rejection():
	yield(get_tree().create_timer(3), "timeout")
	show_hint("Right click to launch an asteroid", 3)
	
func _on_planet_leave():
	print("main planet leave")
	yield(get_tree().create_timer(3), "timeout")
	show_hint(G.rand_dialog("sun_question"), 3, Color.yellow)
	Audio.play("planetvoice1")
	yield(get_tree().create_timer(4), "timeout")
	G.player.speak(G.rand_dialog("sun_defense"), 2, Vector2.ZERO)
	yield(get_tree().create_timer(4), "timeout")
	show_hint("Go talk to the sun", 3)
	for body in $SolarSystem.bodies:
		if body.type == "star":
			body.indvis = true
	
func _on_approached_sun():
	show_hint(G.rand_dialog("sun_ask_stop"), 3, Color.yellow)
	Audio.play("planetvoice1")
	yield(get_tree().create_timer(3.5), "timeout")
	G.player.speak(G.rand_dialog("sun_revolt"), 3, Vector2.ZERO)
	yield(get_tree().create_timer(3.5), "timeout")
	show_hint(G.rand_dialog("sun_ask_leave"), 3, Color.yellow)
	Audio.play("planetvoice1")
	yield(get_tree().create_timer(3.5), "timeout")
	G.player.speak(G.rand_dialog("sun_leave"), 3, Vector2.ZERO)
	yield(get_tree().create_timer(6), "timeout")
	show_hint("Leave the solar system", 5)
	for body in $SolarSystem.bodies:
		if body.type == "exit":
			body.indvis = true
	yield(get_tree().create_timer(6), "timeout")
	for body in $SolarSystem.bodies:
		if body.type == "planet":
			body.indvis = true

func _on_MousePointer_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		G.player.cycle_color()
	
func _on_PlayerName_text_entered(new_text):
	start()
	
func _on_PlayButton_pressed():
	start()

func _on_SettingsButton_pressed():
	pass

func _on_CreditsButton_pressed():
	pass

func _on_QuitButton_pressed():
	get_tree().quit()




