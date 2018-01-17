extends Area2D

export var thrust = 40
export var turn_thrust = 0.2
# both turrets
export var turret_turn_speed = .5
export var turret_return_speed = 1
# left turrets
export var left_arc_start = -30
export var left_arc_end = -150
export var left_turret_rest = -90
# right turrets
export var right_arc_start = 30
export var right_arc_end = 150
export var right_turret_rest = 90
# main gun
export var main_arc_start = -20
export var main_arc_end = 20
export var main_turret_rest = 0

onready var turret_bank_left = get_node("left_bank")
onready var turret_bank_right = get_node("right_bank")
onready var front_gun = get_node("front_gun")
onready var engines = get_node("engines")

var boost_on = false
var thrust_on = false
var turn = 0
var vel = 0
var pos = Vector2()
var rot = 0
var t = 0

func _ready():
	turn_thrust *= 5
	set_process(true)
	
func _process(delta):
	t = 0
	
	if Input.is_action_pressed("player_left"):
		turn -= 0.01
		t = 1
	if Input.is_action_pressed("player_right"):
		turn += 0.01
		t = -1
	if Input.is_action_pressed("player_thrust"):
		if !boost_on:
			vel += 1.5
		thrust_on = true
		
	else:
		if !(boost_on):
			pass
		thrust_on = false
	
	
	pos += Vector2((vel * delta),0).rotated(get_rotation())
	rot += turn * delta
	set_position(pos)
	set_rotation(rot)
	
	if vel > 0:
		vel *= .99
	if turn > 0 or turn < 0:
		turn *= .98

	
	engines(thrust_on,t)
	turret_aim(turret_bank_left, left_arc_start, left_arc_end, left_turret_rest)
	turret_aim(turret_bank_right, right_arc_start, right_arc_end, right_turret_rest)
	turret_aim(front_gun, main_arc_start, main_arc_end, main_turret_rest)

func turret_aim(node,arc_start,arc_end,rest_pos):

	for N in node.get_children():
		var c = rad2deg(N.get_rotation())
		var m = rad2deg(N.get_angle_to(get_global_mouse_position()))
		var m_c = rad2deg(get_angle_to(get_global_mouse_position()))
		if m_c < arc_start and m_c > arc_end:
			if m > 1.5:
				c += turret_turn_speed
			elif m < -1.5: 
				c -= turret_turn_speed
		elif m_c > arc_start and m_c < arc_end:
			if m > 1.5:
				c += turret_turn_speed
			elif m < -1.5: 
				c -= turret_turn_speed
		else:
			
			if c < rest_pos:
				c += turret_return_speed
			elif  c > rest_pos: 
				c -= turret_return_speed
		N.set_rotation(deg2rad(c))

func engines(thrust,turn_thrust):
	for N in engines.get_children():
		N.emitting = thrust
		if N.get_name() == "left" and turn_thrust == -1:
			N.emitting = true
			N.lifetime = 1.8
		elif N.get_name() == "right" and turn_thrust == 1:
			N.emitting = true
			N.lifetime = 1.8
		else:
			N.lifetime = 1


