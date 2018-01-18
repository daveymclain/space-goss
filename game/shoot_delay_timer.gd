extends Timer

signal delay

var turret

func _ready():
	pass

func _on_shoot_delay_timer_timeout():
	if turret < 4:
		get_node("/root/ship").guns_delayed[turret + 1] = false
		
	else:
		get_node("/root/ship").guns_delayed[0] = false
	queue_free()