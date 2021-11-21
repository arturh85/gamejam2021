extends GDBaseEntity

var capacity = 50

func _enter_tree():
	get_parent().energy_max += capacity
func _exit_tree():
	get_parent().energy_max -= capacity
	
