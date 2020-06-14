extends Camera2D

const max_look_ahead = 180

var target
var loose = false

var moving_target

func _ready():
	set_as_toplevel(true)

func _process(delta):
	if loose:
		var v = target.linear_velocity
		var l = v.length()
		var p = 0.1
		if l < 0.01:
			moving_target = target.global_position
		else:
			p = l / target.max_speed
			moving_target = target.global_position + v.normalized() * max_look_ahead * p
		global_position = lerp(global_position, moving_target, p * 0.1)
		#update()
	else:
		global_position = target.global_position

#func _draw():
#	if loose:
#		draw_circle(to_local(moving_target), 3, Color.red)
