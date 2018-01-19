extends Area2D



export var thrust = 1.5
export var turn_thrust = 0.01
# both turrets
export var turret_turn_speed = .5
export var turret_return_speed = .5
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
onready var bullet_container = get_node("bullet_container")
onready var bullet = load("res://scenes/bullet.tscn")
onready var shoot_del_container = get_node("shoot_del_container")
onready var shoot_del = load("res://scenes/shoot_delay_timer.tscn")

# for use later when adding boost
var boost_on = false
var thrust_on = false

# angular momentum
var turn = 0
# linea momentum
var vel = 0
# current position
var pos = Vector2()
# current rotation
var rot = 0
# variable to tell which way the ship its turning. for use when turning the engine particles on
var t = 0
# arrays to see which guns are delayed
var guns_delayed = []
var guns_delayed_right = []
var main_delayed = []

var screensize

func _ready():
	screensize = get_viewport().get_visible_rect().size
	pos = (screensize / 2)
	set_process(true)
	# set all the gun delays to true except the starting guns
	for i in 5:
		guns_delayed.append(true)
	guns_delayed[0] = false
	for i in 5:
		guns_delayed_right.append(true)
	guns_delayed_right[0] = false
	main_delayed.append(false)
func _process(delta):
	t = 0
	if Input.is_action_pressed("player_left"):
		turn -= turn_thrust
		t = 1
	if Input.is_action_pressed("player_right"):
		turn += turn_thrust
		t = -1
	if Input.is_action_pressed("player_thrust"):
		if !boost_on:
			vel += thrust
		thrust_on = true
	else:
		if !(boost_on):
			pass
		thrust_on = false
	
	# particle system for engines
	engines(thrust_on,t)
	pos += Vector2((vel * delta),0).rotated(get_rotation())
	rot += turn * delta
	set_position(pos)
	set_rotation(rot)
	
	# slowly reduce momentum (fake physics)
	if vel > 0:
		vel *= .99
	if turn > 0 or turn < 0:
		turn *= .98
	# turret aiming
	turret_aim(turret_bank_left, left_arc_start, left_arc_end, left_turret_rest, guns_delayed)
	turret_aim(turret_bank_right, right_arc_start, right_arc_end, right_turret_rest, guns_delayed_right)
	turret_aim(front_gun, main_arc_start, main_arc_end, main_turret_rest, main_delayed)

func turret_aim(node, arc_start, arc_end, rest_pos, del_array):
	# var for knowing which turret it is
	var turret_num = 0
	for N in node.get_children():
		
		# curret turret rotation
		var c = rad2deg(N.get_rotation())
		# angle from turret to mouse
		var m = rad2deg(N.get_angle_to(get_global_mouse_position()))
		# angle from ship to mouse
		var m_c = rad2deg(get_angle_to(get_global_mouse_position()))
		# get distance from turret to mouse
		var dis_mouse = N.get_global_position().distance_to(get_global_mouse_position())
		# see if mouse it in its arc and make sure it is not to close
		if m_c < arc_start and m_c > arc_end and dis_mouse > 50:
			# see if the gun delay is on
			if !del_array[turret_num]:
				if Input.is_action_pressed("player_shoot"):
					# set the currect delay index to true 
					del_array[turret_num] = true
					# create an individul timer fot the delay
					var d = shoot_del.instance()
					shoot_del_container.add_child(d)
					# set the turret number in the timer so when it times out it knows which index to set to false again
					d.turret = turret_num
					# start the timer
					d.start()
					var b = bullet.instance()
					bullet_container.add_child(b)
					b.fire(N.get_node("muzzle").get_global_position(),N.get_global_rotation())
				
			if m > 1.5:
				c += turret_turn_speed
			elif m < -1.5: 
				c -= turret_turn_speed
		# the same as above but for the other side
		elif m_c > arc_start and m_c < arc_end and dis_mouse > 50:
			# see if the gun delay is on
			if !del_array[turret_num]:
				if Input.is_action_pressed("player_shoot"):
					# set the currect delay index to true 
					del_array[turret_num] = true
					# create an individul timer fot the delay
					var d = shoot_del.instance()
					shoot_del_container.add_child(d)
					# set the turret number in the timer so when it times out it knows which index to set to false again
					d.turret = turret_num
					# tell the shoot delay timer that it is the right side so it changes the right array
					if del_array.size() > 1:
						d.right = true
					else:
						d.main = true
						d.wait_time = 1
					# start the timer
					d.start()
					var b = bullet.instance()
					bullet_container.add_child(b)
					b.fire(N.get_node("muzzle").get_global_position(),N.get_global_rotation())
			if m > 1.5:
				c += turret_turn_speed
			elif m < -1.5: 
				c -= turret_turn_speed
		# reset the turrets to resting position
		else:
			if c < rest_pos:
				c += turret_return_speed
			elif  c > rest_pos: 
				c -= turret_return_speed
		N.set_rotation(deg2rad(c))
		turret_num += 1

func engines(thrust,turn_thrust):
	for N in engines.get_children():
		# turn on all engines if applying thrust
		N.emitting = thrust
		# when turning right increae particles life in left engine 
		if N.get_name() == "left" and turn_thrust == -1:
			N.emitting = true
			N.lifetime = 1.8
		# when turning left increae particles life in right engine
		elif N.get_name() == "right" and turn_thrust == 1:
			N.emitting = true
			N.lifetime = 1.8
		# return partle system life back to normal
		else:
			N.lifetime = 1


