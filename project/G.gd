extends Node

var rng := RandomNumberGenerator.new()

var unlocked_asteroids = false
var unlocked_planets = false
var unlocked_systems = false

func _ready():
	rng.randomize()
