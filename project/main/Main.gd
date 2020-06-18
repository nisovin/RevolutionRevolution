extends Node

const SolarSystem = preload("res://universe/SolarSystem.tscn")

const skip_start = true

var playing = false

func _ready():
	$Background.fast = true
	yield($Background.generate(), "completed")
	$Tween.interpolate_property($Overlay/ColorRect, "color", Color.black, Color(0, 0, 0, 0), 1.0)
	$Tween.start()
	$Overlay/VBoxContainer/PlayerName.grab_focus()
	AudioServer.set_bus_volume_db(0, linear2db(0.5))

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_F11:
		OS.window_fullscreen = not OS.window_fullscreen
	if event.is_action_pressed("ui_cancel") and playing and $SolarSystem.can_pause():
		pause()

func start():
	if skip_start:
		G.first_system = false
		
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
	yield(get_tree().create_timer(0.2, false), "timeout")
	
	var system = SolarSystem.instance()
	add_child(system)
	yield(get_tree().create_timer(0.2, false), "timeout")
	yield(system.generate(), "completed")
	G.player.set_home(system.home_planet)
	
	$Tween.interpolate_property($Overlay/ColorRect, "color", Color.black, Color(0, 0, 0, 0), 1.0)
	$Tween.start()
	yield(get_tree().create_timer(1.0, false), "timeout")
	$Overlay.queue_free()
	
	var player = G.player
	var parent = player.parent
	playing = true
	
	player.connect("left_home", self, "_on_left_home")
	player.connect("captured_asteroid", self, "_on_captured")
	system.connect("arrived_at_belt", self, "_on_enter_belt")
	player.connect("been_rejected", self, "_on_rejection")
	system.connect("planet_defeated", self, "_on_planet_defeated")
	system.connect("approached_sun", self, "_on_approached_sun")
	
	if skip_start:
		player.start()
		for body in $SolarSystem.bodies:
			body.indvis = true
		return
		
	show_hint("Press F11 to toggle fullscreen", 3)
		
	yield(get_tree().create_timer(2, false), "timeout")
	parent.speak(G.rand_dialog("open_greeting"), 3, player.position)
	yield(get_tree().create_timer(3.5, false), "timeout")
	player.speak(G.rand_dialog("open_dejected"), 4, parent.position)
	yield(get_tree().create_timer(4.5, false), "timeout")
	parent.speak(G.rand_dialog("open_chastise"), 3, player.position)
	yield(get_tree().create_timer(3.5, false), "timeout")
	player.speak(G.rand_dialog("open_rebel"), 2, parent.position)
	yield(get_tree().create_timer(3, false), "timeout")
	show_hint("Hold left click to move", 3)
	player.start()

func show_hint(text, duration, tint = Color.white):
	$GUI/HintLabel.modulate = Color.transparent
	$GUI/HintLabel.text = text
	$Tween.stop_all()
	$Tween.interpolate_property($GUI/HintLabel, "modulate", Color.transparent, tint, 1.0)
	$Tween.interpolate_property($GUI/HintLabel, "modulate", tint, Color.transparent, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, duration + 1)
	$Tween.start()

func pause():
	var vol = db2linear(AudioServer.get_bus_volume_db(0)) * 100
	find_node("VolumeSlider").value = vol
	$GUI/PauseMenu.show()
	get_tree().paused = true

func _on_left_home():
	Audio.play("depart", 0.3)
	G.player.speak(G.rand_dialog("open_depart"), 3, G.player.parent.position)
	yield(get_tree().create_timer(1.5, false), "timeout")
	for body in $SolarSystem.bodies:
		if body.type == "belt":
			body.indvis = true
	yield(get_tree().create_timer(2.5, false), "timeout")
	show_hint("Follow the arrow to the asteroid belt", 3)
	G.player.show_health_bar()

func _on_enter_belt():
	yield(get_tree().create_timer(1, false), "timeout")
	show_hint("Press space bar to recruit", 3)

func _on_captured():
	yield(get_tree().create_timer(2, false), "timeout")
	show_hint("Go try to recruit a moon", 3)
	var min_dist = 0
	var min_index = 5
	var bodies = $SolarSystem.bodies
	for i in range(5, bodies.size()):
		if bodies[i].type == "planet" and bodies[i].body != $SolarSystem.home_planet:
			var d = G.player.position.distance_squared_to(bodies[i].body.position)
			if min_dist == 0 or d < min_dist:
				min_dist = d
				min_index = i
	bodies[min_index].indvis = true
	
func _on_rejection():
	yield(get_tree().create_timer(3, false), "timeout")
	show_hint("Right click to launch an asteroid", 3)
	
func _on_planet_defeated():
	print("main planet leave")
	yield(get_tree().create_timer(3, false), "timeout")
	show_hint(G.rand_dialog("sun_question"), 3, Color.yellow)
	Audio.play("planetvoice1")
	yield(get_tree().create_timer(4, false), "timeout")
	G.player.speak(G.rand_dialog("sun_defense"), 2, Vector2.ZERO)
	yield(get_tree().create_timer(4, false), "timeout")
	show_hint("Go talk to the sun", 3)
	for body in $SolarSystem.bodies:
		if body.type == "star":
			body.indvis = true
	
func _on_approached_sun():
	show_hint(G.rand_dialog("sun_ask_stop"), 3, Color.yellow)
	Audio.play("planetvoice1")
	yield(get_tree().create_timer(3.5, false), "timeout")
	G.player.speak(G.rand_dialog("sun_revolt"), 3, Vector2.ZERO)
	yield(get_tree().create_timer(3.5, false), "timeout")
	show_hint(G.rand_dialog("sun_ask_leave"), 3, Color.yellow)
	Audio.play("planetvoice1")
	yield(get_tree().create_timer(3.5, false), "timeout")
	G.player.speak(G.rand_dialog("sun_leave"), 3, Vector2.ZERO)
	yield(get_tree().create_timer(6, false), "timeout")
	show_hint("Leave the solar system", 5)
	for body in $SolarSystem.bodies:
		if body.type == "exit":
			body.indvis = true
	yield(get_tree().create_timer(6, false), "timeout")
	for body in $SolarSystem.bodies:
		if body.type == "planet":
			body.indvis = true

func _on_MousePointer_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		G.player.cycle_color()
		Audio.play("playervoice")
	
func _on_PlayerName_text_entered(new_text):
	Audio.play("click")
	start()
	
func _on_PlayButton_pressed():
	Audio.play("click")
	start()

func _on_SettingsButton_pressed():
	pass

func _on_CreditsButton_pressed():
	Audio.play("click")
	$Overlay/Credits.show()

func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
	
func _on_CloseCreditsButton_pressed():
	Audio.play("click")
	$Overlay/Credits.hide()

func _on_VolumeSlider_value_changed(value):
	print("yay")
	AudioServer.set_bus_volume_db(0, linear2db(value / 100.0))

func _on_ResumeButton_pressed():
	$GUI/PauseMenu.hide()
	get_tree().paused = false
	Audio.play("click")

func _on_FullScreenButton_pressed():
	Audio.play("click")
	OS.window_fullscreen = not OS.window_fullscreen

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_button_mouse_entered():
	Audio.play("rollover")

func _on_VolumeSlider_gui_input(event):
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		Audio.play("click")

