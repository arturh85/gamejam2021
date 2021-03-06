extends Spatial

const MOVE_MARGIN = 40
const MOVE_SPEED = 30

const ray_length = 1000
onready var cam = $Camera

var team = 0
var selected_units = []
onready var selection_box = $SelectionBox
var start_sel_pos = Vector2()

func _process(delta):
	var world = gamestate.world()
	var selectionTile = world.get_node("SelectionTile")
	if world.mouseInHUD:
		selectionTile.hide()
		return
	selectionTile.show()
	
	var m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos, delta)
	
	var rc = raycast_from_mouse(m_pos, 1)
	var p = world.GroundMap.world_to_map(rc.position)
	
	$"../SelectionTile".translation.x = p.x * world.GroundMap.cell_size.x + world.GroundMap.cell_size.x / 2.0
	$"../SelectionTile".translation.z = p.z * world.GroundMap.cell_size.z + world.GroundMap.cell_size.z / 2.0
	
	var mat1 = $"../SelectionTile/T1".get_surface_material(0)
	var mat2 = $"../SelectionTile/T2".get_surface_material(0)
	var ground_content = world.GroundMap.get_cell_item(p.x, 0, p.z)
	var tree_content = world.TreeMap.get_cell_item(p.x, 0, p.z)
	var building_content = world.BuildingMap.get_cell_item(p.x, 0, p.z)
	if building_content >= 0: # building
		mat1.emission = Color(1, 1, 0)
		mat2.emission = Color(1, 1, 0)
	elif tree_content >= 0: # Trees
		mat1.emission = Color(1, 0, 0)
		mat2.emission = Color(1, 0, 0)
	else: #Grass
		mat1.emission = Color(0.5, 0.5, 0.5)
		mat2.emission = Color(0.5, 0.5, 0.5)
	
	if Input.is_action_just_released("alt_command"):
		$"..".on_click_cell(Vector3(p.x, 0, p.z))
	
	return
	
	if Input.is_action_just_pressed("main_command"):
		move_selected_units(m_pos)
	if Input.is_action_just_pressed("alt_command"):
		selection_box.start_sel_pos = m_pos
		start_sel_pos = m_pos
	if Input.is_action_pressed("alt_command"):
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("alt_command"):
		select_units(m_pos)

func calc_move(m_pos, delta):
	var v_size = get_viewport().size
	var move_vec = Vector3()
	if m_pos.x < MOVE_MARGIN or Input.is_action_pressed("ui_left"):
		move_vec.x -= 1
	if m_pos.y < MOVE_MARGIN or Input.is_action_pressed("ui_up"):
		move_vec.z -= 1
	if m_pos.x > v_size.x - MOVE_MARGIN or Input.is_action_pressed("ui_right"):
		move_vec.x += 1
	if m_pos.y > v_size.y - MOVE_MARGIN or Input.is_action_pressed("ui_down"):
		move_vec.z += 1
	
	var shift_multiplier = 1
	if Input.is_key_pressed(KEY_SHIFT):
		shift_multiplier = 3
		
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
	global_translate(move_vec * delta * MOVE_SPEED * shift_multiplier)

func move_selected_units(m_pos):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		for unit in selected_units:
			unit.move_to(result.position)

func select_units(m_pos):

	return
	
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 16999999:
		var u = raycast_from_mouse(m_pos, 1)
		if u != null:
			#$"../SelectionTile" = u.position
			print(u.position)
		#	new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		for unit in selected_units:
			unit.deselect()
		for unit in new_selected_units:
			unit.select()
		selected_units = new_selected_units

func get_unit_under_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	if result and "team" in result.collider and result.collider.team == team:
		return result.collider

func get_units_in_box(top_left, bot_right):
	if top_left.x > bot_right.x:
		var tmp = top_left.x
		top_left.x = bot_right.x
		bot_right.x = tmp
	if top_left.y > bot_right.y:
		var tmp = top_left.y
		top_left.y = bot_right.y
		bot_right.y = tmp
	var box = Rect2(top_left, bot_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == team and box.has_point(cam.unproject_position(unit.global_transform.origin)):
			box_selected_units.append(unit)
	return box_selected_units

func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * ray_length
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(ray_start, ray_end, [], collision_mask)
