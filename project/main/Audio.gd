extends Node

var _sfx_node = null
var _sfx_sounds = {}
var _music_players = []
var _music_active = -1
var _music_tween : Tween = null

func _ready():
	init()
	register("depart", preload("res://sounds/depart.ogg"))
	register("launch", preload("res://sounds/flaunch.wav"))
	register("break", preload("res://sounds/break.ogg"))

func init(channels = 10):
	_sfx_node = Node.new()
	_sfx_node.name = "SFX"
	add_child(_sfx_node)
	for i in channels:
		_sfx_node.add_child(AudioStreamPlayer.new())

func register(key, sound):
	_sfx_sounds[key] = sound

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
