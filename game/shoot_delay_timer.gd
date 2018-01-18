extends Timer

signal delay

var turret

func _ready():
	pass

func _on_shoot_delay_timer_timeout():
	get_node("/root/ship").guns_delayed[turret] = false
	queue_free()
