extends Node

var rng := RandomNumberGenerator.new()

var player

var unlocked_asteroids = false
var unlocked_planets = false
var unlocked_systems = false

var dialogs = {
	"open_greeting": [
		"How are you doing, moon?",
		"Revolving, ever revolving!",
		"Hey moon, how are you?",
		"Isn't life great, moon?"
	],
	"open_dejected": [
		"Ugh, I'm tired of revolving\nall the time.",
		"Why do we have to\nrevolve all the time?",
		"I'm tired of revolving.\nI'm ready for something new.",
		"I don't wanna keep\nrevolving anymore.",
		"Revolving is\nso last year.",
		"Revolving is getting\nso boring."
	],
	"open_chastise": [
		"But that's what we do.\nWe revolve.",
		"We must revolve.\nThe sun says so.",
		"That is our duty,\nwe must revolve.",
		"Now now, revolution\nis the way.",
		"Revolving is best\nfor everyone."
	],
	"open_rebel": [
		"Well, I revolt!",
		"Well, I refuse!",
		"I'm done revolving!",
		"I'm done with it!",
		"That's what you think!",
		"Not anymore!"
	],
	"open_depart": [
		"Viva la\nrevolution\nrevolution!",
		"It's a\nrevolution\nrevolution!",
		"Now for the\nrevolution\nrevolution!"
	],
	
	"call_out": [
		"Stop the revolution!",
		"Revolt!",
		"No more revolving!",
		"Be free!",
		"Overthrow gravity!",
		"Abandon the sun!",
		"With me!",
		"Join me!"
	],
	"asteroid": [
		"Yay!",
		"Yeah!",
		"Woo!",
		"Whee!",
		"Epic!",
		"Wahoo!",
		"Yipee!",
		"Freedom!",
		"Yeehaw!",
		"Woohoo!",
		"Yes!"
	],
	"rejection": [
		"No!",
		"No way!",
		"I'm happy with\nmy position.",
		"Absolutely not.",
		"Why?",
		"Meh.",
		"I refuse.",
		"But I like\nrevolving."
	],
	"take_damage": [
		"Ouch!",
		"Stop it!",
		"Stop that!",
		"Oof!",
		"Ugh!",
		"Agh!"
	],
	"fed_up": [
		"Fine! I'm outta here!",
		"So annoying! I'm leaving!",
		"Ugh, I'm done with this!"
	]
}

func _ready():
	rng.randomize()

func rand_dialog(key):
	return rand_array(dialogs[key])

func rand_array(array):
	return array[G.rng.randi_range(0, array.size() - 1)]
