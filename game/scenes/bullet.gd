extends Area2D

var vel = Vector2()
var speed = 500

func _ready():
	set_process(true)

func _process(delta):
	set_position(get_position() + vel * delta)
func fire(t_start_pos,t_rot):
	set_rotation(t_rot)
	set_position(t_start_pos)
	vel = Vector2(speed,0).rotated(t_rot)
	