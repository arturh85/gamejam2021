extends GDBaseEntity


var burntime = 0.0
#can_catch_fire = true


	

func on_catch_fire():
	burntime += 5.0

func _process(delta):
	var damage = delta * 3
	if burntime > 0:
		burntime -= delta
		health_current -= damage
	if health_current <= 0:
		$"..".on_tree_burndown(self.grid_pos)
	else:
		$HealthDisplay.update_healthbar(health_current, health_max)
