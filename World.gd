extends Spatial



var wind_direction = 0
signal wind_direction_changed

var resources = 10
signal resources_changed

var energy = 10
signal energy_changed

var co2_level = 0
signal co2_level_changed

var fires = {}

var rng = RandomNumberGenerator.new()


var TreeMap
var GroundMap

func _ready():
	TreeMap = get_node("./TreeMap")
	GroundMap = get_node("./GroundMap")
	rng.randomize()
	
	if TreeMap:
		randomizeTreeMap()
		
func _random_element(list):
	var random_idx = rng.randi_range(0, list.size())
	return list[random_idx]

func randomizeTreeMap():
	TreeMap.clear()
	
	var num_seed_trees = 20
	var available_cells = GroundMap.get_used_cells()
	for i in range(num_seed_trees):
		var pos = _random_element(available_cells)
		TreeMap.set_cell_item(pos.x, pos.y, pos.z, 0)
	_update_tree_growth()
	_update_tree_growth()
	_update_tree_growth()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_fire(x, z):
	var key = str(x) + "," + str(z)
	if not fires.has(key):
		var scene = load("res://effects/Fire.tscn")
		var instance = scene.instance()
		instance.translation = TreeMap.map_to_world(x, 0, z)
		add_child(instance)
		fires[key] = instance
		
func _cells_around8(center):
	var neighbors = []
	for x in range(center.x-1, center.x+2):
		for z in range(center.z-1, center.z+2):
			if x != center.x or z != center.z:
				neighbors.append(Vector3(x, center.y, z))
	return neighbors
	
func _cells_around4(center):
	var neighbors = []
	neighbors.append(Vector3(center.x - 1, center.y, center.z))
	neighbors.append(Vector3(center.x, center.y, center.z - 1))
	neighbors.append(Vector3(center.x + 1, center.y, center.z))
	neighbors.append(Vector3(center.x, center.y, center.z + 1))
	return neighbors
	
func _spread_fire(pos):
	var fires_to_add = []
	var key = str(pos.x) + "," + str(pos.z)
	if fires.has(key):
		var instance = fires[key]
		instance.ticks_burning += 1
		co2_level += instance.ticks_burning
		if rng.randf_range(0, 10) < instance.ticks_burning*2 :
			fires[key].queue_free()
			fires.erase(key)
		for n in _cells_around8(pos):
			var direction_factor = 0.1
			if wind_direction == 0: # North
				if n.z > pos.z:
					direction_factor = 0.8
			elif wind_direction == 1: # East
				if n.x > pos.x:
					direction_factor = 0.8
			elif wind_direction == 2: # South
				if n.z > pos.z:
					direction_factor = 0.8
				pass
			else:                         # West
				if n.x < pos.x:
					direction_factor = 0.8
				pass

			var kkey =  str(n.x) + "," + str(n.z)
			var cell_content = TreeMap.get_cell_item(n.x,0, n.z)
			if cell_content >= 0: # Trees
				if rng.randf_range(0, 1) < direction_factor:
					fires_to_add.append([n.x, n.z])
	return fires_to_add

func _update_tree_growth():
	for cell in TreeMap.get_used_cells():
		var tree_type = TreeMap.get_cell_item(cell.x, cell.y, cell.z)
		if rng.randi_range(0, 100) > 50:
			continue
		for n in _cells_around8(cell):
			var n_content = TreeMap.get_cell_item(n.x, n.y, n.z)
			var n_ground = GroundMap.get_cell_item(n.x, n.y, n.z)
			if n_ground == 1 and n_content == -1 and rng.randi_range(0, 100) > 50:
				TreeMap.set_cell_item(n.x, n.y, n.z, tree_type)
		
func _update_fire_spread():
	var fires_to_add = []

	var old_co2_level = co2_level

	for cell in TreeMap.get_used_cells():
		for pos in _spread_fire(cell):
			fires_to_add.append(pos)
	for key in fires_to_add:
		add_fire(key[0], key[1])
	if old_co2_level != co2_level:
		emit_signal("co2_level_changed", co2_level)

func _update_wind_direction():
	var wind_change = rng.randf_range(-10.0, 10.0)
	if wind_change < -8.9:
		wind_direction = wrapi(wind_direction - 1, 0, 4)
		emit_signal("wind_direction_changed", wind_direction)
	if wind_change > 8.9:
		wind_direction = wrapi(wind_direction + 1, 0, 4)
		emit_signal("wind_direction_changed", wind_direction)


func _on_Timer_timeout():
	_update_wind_direction()
	if rng.randi_range(0, 100) > 70:
		_update_fire_spread()
	if rng.randi_range(0, 100) > 95:
		_update_tree_growth()
