extends Node

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	
	yield($SolarSystem.generate(true), "completed")
	
	var player = G.player
	var parent = player.parent
	
	player.connect("left_home", self, "_on_left_home")
	player.connect("captured_asteroid", self, "_on_captured")
	
	yield(get_tree().create_timer(2), "timeout")
	parent.speak(G.rand_dialog("open_greeting"), 3, player.position)
	yield(get_tree().create_timer(3.5), "timeout")
	player.speak(G.rand_dialog("open_dejected"), 4, parent.position)
	yield(get_tree().create_timer(4.5), "timeout")
	parent.speak(G.rand_dialog("open_chastise"), 3, player.position)
	yield(get_tree().create_timer(3.5), "timeout")
	player.speak(G.rand_dialog("open_rebel"), 2, parent.position)
	yield(get_tree().create_timer(2.5), "timeout")
	player.start()

func _on_left_home():
	Audio.play("depart", 0.3)
	G.player.speak(G.rand_dialog("open_depart"), 3, G.player.parent.position)
	for body in $SolarSystem.bodies:
		if body.type == "belt":
			body.indvis = true

func _on_enter_belt():
	pass

func _on_captured():
	for body in $SolarSystem.bodies:
		if body.type == "planet":
			body.indvis = true
	
func _on_rejection():
	pass
	
func _on_recruit_planet():
	pass
	
func _on_talk_sun():
	pass
