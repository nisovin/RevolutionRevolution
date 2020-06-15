extends Node

var _sfx_node = null
var _sfx_sounds = {}
var _wormhole_sound
var _wormhole_tween : Tween
var _music_players = []
var _music_active = -1
var _music_tween : Tween = null

func _ready():
	init()
	init_wormhole()
	register("depart", preload("res://sounds/depart.ogg"))
	register("launch", preload("res://sounds/flaunch.wav"))
	register("break", preload("res://sounds/break.ogg"))
	
	for i in 10:
		register("playervoice" + str(i+1), load("res://sounds/player_voice-" + str(i+1).pad_zeros(2) + ".ogg"))
	for i in 9:
		register("asteroidvoice" + str(i+1), load("res://sounds/asteroid_voice-" + str(i+1).pad_zeros(2) + ".ogg"))
	for i in 9:
		for j in 3:
			register("planetvoice" + str(i+1) + "_" + str(j+1), load("res://sounds/planet" + str(i+1) + "-voice-0" + str(j+1) + ".ogg"))

func init(channels = 10):
	_sfx_node = Node.new()
	_sfx_node.name = "SFX"
	add_child(_sfx_node)
	for i in channels:
		_sfx_node.add_child(AudioStreamPlayer.new())
		
func init_wormhole():
	_wormhole_tween = Tween.new()
	add_child(_wormhole_tween)
	_wormhole_sound = AudioStreamPlayer.new()
	add_child(_wormhole_sound)
	_wormhole_sound.stream = preload("res://sounds/wormhole.ogg")
	_wormhole_sound.volume_db = linear2db(0)
	_wormhole_sound.play()

func register(key, sound):
	_sfx_sounds[key] = sound

func play_player_voice():
	play("playervoice" + str(G.rng.randi_range(1, 10)))
	
func play_planet_voice(p):
	play("planetvoice" + str(p) + "_" + str(G.rng.randi_range(1, 3)))

func play_wormhole():
	_wormhole_tween.stop_all()
	_wormhole_tween.interpolate_method(self, "_tween_wormhole", db2linear(_wormhole_sound.volume_db), 1, 2)
	_wormhole_tween.start()
	
func stop_wormhole():
	_wormhole_tween.stop_all()
	_wormhole_tween.interpolate_method(self, "_tween_wormhole", db2linear(_wormhole_sound.volume_db), 0, 2)
	_wormhole_tween.start()

func _tween_wormhole(vol):
	_wormhole_sound.volume_db = linear2db(vol)
	
func play(sound, volume = 1.0, force = false, bus = "SFX"):
	for a in _sfx_node.get_children():
		if not a.playing:
			a.volume_db = linear2db(volume)
			a.bus = bus
			if sound is String:
				a.stream = _sfx_sounds[sound]
			elif sound is AudioStream:
				a.stream = sound
			a.play()
			return
	if force:
		var a = G.rand_array(_sfx_node.get_children())
		a.stop()
		a.volume_db = linear2db(volume)
		a.bus = bus
		a.stream = sound
		a.play()
