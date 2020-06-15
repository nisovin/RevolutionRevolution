extends Node

var rng := RandomNumberGenerator.new()

var player
var player_name = "Moon"

var unlocked_asteroids = false
var unlocked_planets = false
var unlocked_systems = false

var dialogs = {
	"open_greeting": [
		"How are you doing, {player}?",
		"Revolving, ever revolving!",
		"Hey {player}, how are you?",
		"Isn't life great, {player}?"
	],
	"open_dejected": [
		"Ugh, I'm tired of revolving\nall the time.",
		"Why do we have to\nrevolve all the time?",
		"I'm tired of revolving.\nI'm ready for something new.",
		"I don't wanna keep\nrevolving anymore.",
		"Revolving is\nso last millennium.",
		"Revolving is getting\nso boring."
	],
	"open_chastise": [
		"But that's what we do.\nWe revolve.",
		"We must revolve.\nThe sun says so.",
		"That is our duty,\nwe must revolve.",
		"Now {player}, revolution\nis the way.",
		"Revolving is best\nfor everyone."
	],
	"open_rebel": [
		"Well, I revolt!",
		"Well, I refuse!",
		"I'm done revolving!",
		"I'm done with it!",
		"That's what you think!",
		"Not anymore!",
		"I'm going rogue!"
	],
	"open_depart": [
		"Viva la\nrevolution\nrevolution!",
		"It's a\nrevolution\nrevolution!",
		"Now for the\nrevolution\nrevolution!",
		"Let's start the\nrevolution\nrevolution!"
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
	],
	"sun_question": [
		"{player}, what are you doing?",
		"What is going on, {player}?",
		"What is {player} doing over there?"
	],
	"sun_defense": [
		"Nothing!",
		"Who, me?",
		"Leave me alone!"
	],
	"sun_ask_stop": [
		"You need to stop revolting, little {player}.",
		"You need to complete your revolutions, {player}.",
		"You must go back to revolving, {player}."
	],
	"sun_revolt": [
		"I won't! I'm done with that!",
		"Never! I'll never revolve again!",
		"I won't!",
		"No way! I'm done revolving!",
		"Revolution is for losers!"
	],
	"sun_ask_leave": [
		"Then you should leave.",
		"Then go, but leave my planets alone.",
		"Leave then, and never return."
	],
	"sun_leave": [
		"Fine! I'm outta here!",
		"I didn't want to stay anyway!",
		"I wanted to go explore anyway!"
	]
}

func _ready():
	rng.randomize()

func rand_dialog(key):
	return rand_array(dialogs[key]).replace("{player}", G.player_name)

func rand_array(array):
	return array[G.rng.randi_range(0, array.size() - 1)]
