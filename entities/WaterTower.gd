extends GDBaseEntity

	
func _on_WorkTimer_timeout():
	var cost_energy = 10
	var world = gamestate.world()
	for cell in world.fire_effects.keys():
		var d = cell.distance_to(grid_pos)
		if d < 4 and world.energy_current > cost_energy:
			if world.tree_entities.has(cell):
				world.tree_entities[cell].on_water()
			if world.building_entities.has(cell):
				world.building_entities[cell].on_water()
			
			world.fire_effects[cell].queue_free()
			world.fire_effects.erase(cell)
			world.reduce_energy(cost_energy)
			break
			
