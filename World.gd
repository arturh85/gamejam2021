extends Spatial



var dayDuration = 60.0 #seconds
var sunHours = 2.0
var fadeTimeHours = 1.0

var wind_direction = 0
signal wind_direction_changed

var resources = 10
signal resources_changed

var energy = 10
signal energy_changed

var co2_level = 0
signal co2_level_changed

var fire_effects = {}
var tree_entities = {}
var building_entities = {}

var rng = RandomNumberGenerator.new()

var theTime = 0.0


var TreeMap
var BuildingMap
var GroundMap
var SceneFire
var SceneEntityTree
var SceneEntityBattery
var SceneEntityHeadquarter
var SceneEntityPowerLine
var SceneEntitySolarCell
var SceneEntityFarm
var SceneEntityWaterTower
var SceneEntitySilo
var SceneHealth

func _ready():
	TreeMap = get_node("TreeMap")
	BuildingMap = get_node("BuildingMap")
	GroundMap = get_node("GroundMap")
	SceneFire = load("res://effects/Fire.tscn")
	SceneEntityTree = load("res://entities/Tree.tscn")
	SceneEntityBattery = load("res://entities/Battery.tscn")
	SceneEntityHeadquarter = load("res://entities/Headquarter.tscn")
	SceneEntityPowerLine = load("res://entities/PowerLine.tscn")
	SceneEntitySolarCell = load("res://entities/SolarCell.tscn")
	SceneEntityFarm = load("res://entities/Farm.tscn")
	SceneEntityWaterTower = load("res://entities/WaterTower.tscn")
	SceneEntitySilo = load("res://entities/Silo.tscn")
	SceneHealth = load("res://HealthDisplay.tscn")
	rng.randomize()
	
	if TreeMap:
		randomizeTreeMap()
		_update_buildings()
		
func _random_element(list):
	var random_idx = rng.randi_range(0, list.size()-1)
	return list[random_idx]

func randomizeTreeMap():
	TreeMap.clear()
	
	var num_seed_trees = 20
	var available_cells = GroundMap.get_used_cells()
	for i in range(num_seed_trees):
		var pos = _random_element(available_cells)
		if _is_allowed_tree(pos):
			TreeMap.set_cell_item(pos.x, pos.y, pos.z, rng.randi_range(0, TreeMap.mesh_library.get_item_list().size()-1))
	
	_update_tree_growth(true)
	_update_tree_growth(false)
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	var env = get_node_or_null("WorldEnvironment")
	
	if env:
		var mono = get_node("CanvasLayer/MonochromeShader")
		var clockText = get_node("CanvasLayer/HUD-Status/Label-Clock")
		
		theTime = theTime + delta
		var daytime = theTime
		while daytime > dayDuration:
			daytime = daytime - dayDuration
		
		var h = floor(daytime / dayDuration * 24)
		var m = str(int((daytime / dayDuration * 24 - h) * 60.0))
		if m.length() == 1:
			m = "0" + m
		clockText.text = str(int(h)) + ":" + m
				
		var sunS = sunHours * dayDuration / 24.0
		var fadeTimeS = fadeTimeHours * dayDuration / 24.0
			
		if daytime > (dayDuration - sunS) / 2.0 and daytime < (dayDuration + sunS) / 2.0:
			mono.modulate = Color(1, 1, 1, 1)
			env.environment.ambient_light_color = Color(1, 1, 1, 1)
		elif daytime > (dayDuration - sunS - fadeTimeS*2.0) / 2.0 and daytime <= (dayDuration - sunS) / 2.0:
			var d =  (daytime - (dayDuration - sunS - fadeTimeS*2.0) / 2.0) / fadeTimeS
			var t = 0.1 + d*0.9
			mono.modulate = Color(1, 1, 1, d)
			env.environment.ambient_light_color = Color(t, t, t, 1)
		elif daytime >= (dayDuration + sunS) / 2.0 and daytime < (dayDuration + sunS + fadeTimeS*2.0) / 2.0:
			var d =  ((dayDuration + sunS + fadeTimeS*2.0) / 2.0 - daytime) / fadeTimeS
			var t = 0.1 + d*0.9
			mono.modulate = Color(1, 1, 1, d)
			env.environment.ambient_light_color = Color(t, t, t, 1)
		else:
			mono.modulate = Color(1, 1, 1, 0)
			env.environment.ambient_light_color = Color(0.1, 0.1, 0.1, 1)
		
func damage_tree(key):
	pass

func on_click_cell(pos: Vector3):
	var options = $"CanvasLayer/HUD-Tool/OptionButton"
	if options.selected == 0: # Fire
		var tree_content = TreeMap.get_cell_item(pos.x, pos.y, pos.z)
		if tree_content != -1:
			add_fire(pos)
	elif options.selected == 1: # Tree
		var building_content = BuildingMap.get_cell_item(pos.x, pos.y, pos.z)
		if building_content == -1:
			TreeMap.set_cell_item(pos.x, pos.y, pos.z, 1)
	elif options.selected == 2: # Bulldozer
		self.on_burndown(pos)
	elif options.selected == 3: # SolarCell
		BuildingMap.set_cell_item(pos.x, pos.y, pos.z, 0) # SolarCell
		self._update_buildings()
	elif options.selected == 4: # Battery
		BuildingMap.set_cell_item(pos.x, pos.y, pos.z, 7) # Battery
		self._update_buildings()
	elif options.selected == 5: # PowerLine
		BuildingMap.set_cell_item(pos.x, pos.y, pos.z, 1) # PowerLine
		self._update_buildings()
	elif options.selected == 6: # Farm
		BuildingMap.set_cell_item(pos.x, pos.y, pos.z, 8) # Farm
		self._update_buildings()
	elif options.selected == 7: # WaterTower
		BuildingMap.set_cell_item(pos.x, pos.y, pos.z, 9) # WaterTower
		self._update_buildings()
	elif options.selected == 8: # Silo
		BuildingMap.set_cell_item(pos.x, pos.y, pos.z, 10) # Silo
		self._update_buildings()
	else:
		print("ERROR: unknown selected: ", options.selected)

func mine_tree(pos: Vector3):
	var tree_content = TreeMap.get_cell_item(pos.x, pos.y, pos.z)

	if fire_effects.has(pos):
		fire_effects[pos].queue_free()
		fire_effects.erase(pos)
	if tree_entities.has(pos):
		tree_entities[pos].queue_free()
		tree_entities.erase(pos)
	TreeMap.set_cell_item(pos.x, pos.y, pos.z, -1)

	resources += 10
	emit_signal("resources_changed", resources)


func add_fire(pos: Vector3):
	if not fire_effects.has(pos):
		var fire_instance = SceneFire.instance()
		fire_instance.translation = GroundMap.map_to_world(pos.x, pos.y, pos.z)
		add_child(fire_instance)
		fire_effects[pos] = fire_instance
		
		var tree_content = TreeMap.get_cell_item(pos.x, pos.y, pos.z)
		if tree_content != -1:
			if not tree_entities.has(pos):
				var tree_instance = SceneEntityTree.instance()
				tree_instance.translation = GroundMap.map_to_world(pos.x, pos.y, pos.z)
				tree_instance.grid_pos = pos
				add_child(tree_instance)
				tree_entities[pos] = tree_instance
			tree_entities[pos].on_catch_fire()
		var building_content = BuildingMap.get_cell_item(pos.x, pos.y, pos.z)
		if building_content != -1:
			if building_entities.has(pos):
				building_entities[pos].on_catch_fire()
				
func on_burndown(pos):
	if fire_effects.has(pos):
		fire_effects[pos].queue_free()
		fire_effects.erase(pos)
	if tree_entities.has(pos):
		tree_entities[pos].queue_free()
		tree_entities.erase(pos)
	if building_entities.has(pos):
		building_entities[pos].queue_free()
		building_entities.erase(pos)
	TreeMap.set_cell_item(pos.x, pos.y, pos.z, -1)
	BuildingMap.set_cell_item(pos.x, pos.y, pos.z, -1)
		
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
	neighbors.append(Vector3(center.x,     center.y, center.z - 1))
	neighbors.append(Vector3(center.x + 1, center.y, center.z))
	neighbors.append(Vector3(center.x,     center.y, center.z + 1))
	return neighbors
	
func _spread_fire(pos: Vector3):
	var fires_to_add = []
	if fire_effects.has(pos):
		var instance = fire_effects[pos]
		instance.ticks_burning += 1
		co2_level += instance.ticks_burning
		for n in _cells_around8(pos):
			var direction_factor = 0.1
			if wind_direction == 0: # North
				if n.z < pos.z:
					direction_factor = 0.8
			elif wind_direction == 1: # East
				if n.x > pos.x:
					direction_factor = 0.8
			elif wind_direction == 2: # South
				if n.z > pos.z:
					direction_factor = 0.8
			else:                         # West
				if n.x < pos.x:
					direction_factor = 0.8

			var tree_content = TreeMap.get_cell_item(n.x, n.y, n.z)
			var building_content = BuildingMap.get_cell_item(n.x, n.y, n.z)
			if tree_content >= 0:
				if rng.randf_range(0, 1) < direction_factor:
					fires_to_add.append(n)
			elif building_content >= 0: 
					fires_to_add.append(n)
	return fires_to_add
	
func _is_allowed_tree(n):
	var n_ground = GroundMap.get_cell_item(n.x, n.y, n.z)
	var n_building = BuildingMap.get_cell_item(n.x, n.y, n.z)
	return n_ground == 1 and n_building == -1

func _update_tree_growth(force):
	for cell in TreeMap.get_used_cells():
		var tree_type = TreeMap.get_cell_item(cell.x, cell.y, cell.z)
		if !force && rng.randi_range(0, 100) < 80:
			continue
		for n in _cells_around8(cell):
			var n_content = TreeMap.get_cell_item(n.x, n.y, n.z)
			if _is_allowed_tree(n) and n_content == -1 and (force or rng.randi_range(0, 100) > 80):
				TreeMap.set_cell_item(n.x, n.y, n.z, rng.randi_range(0, TreeMap.mesh_library.get_item_list().size()-1))
		
func _update_fire_spread():
	var fires_to_add = []

	var old_co2_level = co2_level

	for cell in TreeMap.get_used_cells():
		for pos in _spread_fire(cell):
			fires_to_add.append(pos)
	for pos in fires_to_add:
		add_fire(pos)
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


func _update_buildings():
	for cell in BuildingMap.get_used_cells():
		var btype = BuildingMap.get_cell_item(cell.x, cell.y, cell.z)
		if btype != -1:
			for n in _cells_around8(cell):
				GroundMap.set_cell_item(n.x, n.y, n.z, 0)
		
		if not building_entities.has(cell):
			var building_instance = null
			if btype == 0:
				building_instance = SceneEntitySolarCell.instance()
			elif btype >= 1 and btype <= 5:
				building_instance = SceneEntityPowerLine.instance()
			elif btype == 6:
				building_instance = SceneEntityHeadquarter.instance()
			elif btype == 7:
				building_instance = SceneEntityBattery.instance()
			elif btype == 8:
				building_instance = SceneEntityFarm.instance()
			elif btype == 9:
				building_instance = SceneEntityWaterTower.instance()
			elif btype == 10:
				building_instance = SceneEntitySilo.instance()
			else:
				print("ERROR: unknown building type", btype)
				continue
				
			building_instance.translation = GroundMap.map_to_world(cell.x, cell.y, cell.z)
			building_instance.grid_pos = cell
			add_child(building_instance)
			building_entities[cell] = building_instance
			

func _on_SpreadEffectsTimer_timeout():
	if rng.randi_range(0, 100) > 30:
		_update_fire_spread()


func _on_TreeGrowthTimer_timeout():
	_update_tree_growth(false)



func _on_WindDirectionTimer_timeout():
	_update_wind_direction()

func _on_DisasterTimer_timeout():
	var disaster_type = rng.randi_range(0, 0)
	if disaster_type == 0:
		var fire_count = rng.randi_range(1, 2)
		print("disaster: fire x ", fire_count, "after", $"DisasterTimer".wait_time )
		var trees = TreeMap.get_used_cells()
		for i in range(fire_count):
			var pos = _random_element(trees)
			add_fire(pos)

	$"DisasterTimer".wait_time += 5
