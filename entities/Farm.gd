extends GDBaseEntity


func _on_WorkTimer_timeout():
	var tree_map = $"../TreeMap"
	for cell in tree_map.get_used_cells():
		var d = cell.distance_to(grid_pos)
		if d < 4:
			$"..".mine_tree(cell)
			break
