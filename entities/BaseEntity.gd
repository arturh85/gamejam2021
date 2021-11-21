extends Spatial

class_name GDBaseEntity

var grid_pos: Vector3
var health_max = 20
var health_current = 20
var can_catch_fire = false


var burntime = 0.0
#can_catch_fire = true


	

func on_catch_fire():
	burntime += 15.0

func on_water():
	burntime = 0

func _process(delta):
	var damage = delta * 3
	if burntime > 0:
		burntime -= delta
		health_current -= damage
	elif health_current < health_max:
		health_current = clamp(health_current + delta / 2, 0, health_max)
	if health_current <= 0:
		$"..".on_burndown(self.grid_pos)
	else:
		$HealthDisplay.update_healthbar(health_current, health_max)
