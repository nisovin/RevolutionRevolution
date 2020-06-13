extends Node2D

var color = Color.white
var type = "planet"
var lbl_dist = 15

onready var label_pos = $Label.rect_position

func _ready():
	$Label.modulate = color.lightened(0.7)
	if type == "asteroids": lbl_dist = 18
	elif type == "exit": lbl_dist = 25

func set_arrow_rotation(rot):
	$Arrow.rotation = rot
	$Label.rect_position = label_pos + Vector2.LEFT.rotated(rot) * lbl_dist

func set_label_text(text):
	$Label.text = text
