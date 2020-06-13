extends Node2D

var color = Color.white

onready var label_pos = $Label.rect_position

func _ready():
	$Label.modulate = color.lightened(0.7)

func set_arrow_rotation(rot):
	$Arrow.rotation = rot
	$Label.rect_position = label_pos + Vector2.LEFT.rotated(rot) * 15

func set_label_text(text):
	$Label.text = text
