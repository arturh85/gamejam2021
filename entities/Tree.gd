extends GDBaseEntity


var burntime = 0.0
#can_catch_fire = true


	

func on_catch_fire():
	burntime = 10.0

func _process(delta):
	burntime -= delta
	if burntime <= 0:
		$"..".on_tree_burndown(self.grid_pos)
	else:
		$HealthDisplay.update_healthbar(burntime, 300.0)
