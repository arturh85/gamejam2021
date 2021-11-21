extends GDBaseEntity

var colBusy = Color(1, 1, 0, 1)
var colAction = Color(0, 1, 0, 1)
var colIdle = Color(1, 0, 0, 1)

var newmat
func _ready():
	newmat = $"Farm".get_surface_material(5).duplicate()
	$"Farm".set_surface_material(5, newmat)
	$"Farm".set_surface_material(7, newmat)
	
	update_material(colBusy)
	
func _on_WorkTimer_timeout():
	
	var tree_map = $"../TreeMap"
	
	var cells = 0
	for cell in tree_map.get_used_cells():
		var d = cell.distance_to(grid_pos)
		if d < 4:
			cells = cells + 1
			update_material(colAction)
			$"..".mine_tree(cell)
			yield(get_tree().create_timer(0.5), "timeout")
			update_material(colBusy)
			break
			
	if cells == 0:
		update_material(colIdle)
			
func update_material(color):

	newmat.emission = color
	newmat.albedo_color = color
	
