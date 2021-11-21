extends GDBaseEntity


var energy_per_tick = 30

func _ready():
	pass
	


func _on_CollectTimer_timeout():
	var world = get_parent()
	var energy = clamp(energy_per_tick * world.lightFactor, 1, 200)
	world.add_energy(energy)
