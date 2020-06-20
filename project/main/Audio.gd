extends Node

var _sfx_node = null
var _sfx_sounds = {}
var _wormhole_sound
var _wormhole_tween : Tween
var _music_players = []
var _music_active = -1
var _music_tween : Tween = null

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	init()
	init_wormhole()
	register("rollover", preload("res://sounds/rollover6.ogg"))
	register("click", preload("res://sounds/click4.ogg"))
	register("depart", preload("res://sounds/depart.ogg"))
	register("launch", preload("res://sounds/flaunch.wav"))
	register("iceball", preload("res://sounds/iceball.wav"))
	register("break", preload("res://sounds/break.ogg"))
	register("comethit", preload("res://sounds/comet_hit.ogg"))
	register("sunattack", preload("res://sounds/foom_bartk.wav"))
	register("sunhit", preload("res://sounds/spell_fire_06.ogg"))
	register("collect", preload("res://sounds/collect.ogg"))
	register("levelup", preload("res://sounds/levelup.ogg"))
	register("ringbreak", preload("res://sounds/ringbreak.ogg"))
	register("gameover", preload("res://sounds/gameover.ogg"))

	for i in 3:
		register("thwack", load("res://sounds/thwack-0" + str(i+1) + ".ogg"))
	
	for i in 10:
		register("playervoice", load("res://sounds/player_voice-" + str(i+1).pad_zeros(2) + ".ogg"))
	for i in 9:
		register("asteroidvoice", load("res://sounds/asteroid_voice-" + str(i+1).pad_zeros(2) + ".ogg"))
	for i in 9:
		for j in 3:
			register("planetvoice" + str(i+1), load("res://sounds/planet" + str(i+1) + "-voice-0" + str(j+1) + ".ogg"))

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
	if not key in _sfx_sounds:
		_sfx_sounds[key] = []
	_sfx_sounds[key].append(sound)

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
				a.stream = G.rand_array(_sfx_sounds[sound])
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
