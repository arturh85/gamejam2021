extends Spatial


onready var TreeMap = get_node("TreeMap")
onready var GroundMap = get_node("GroundMap")

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

var fires = {}

var rng = RandomNumberGenerator.new()

var theTime = 0.0

func _ready():
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	var env = get_node("WorldEnvironment")
	
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
		
		

func add_fire(x, z):
	var key = str(x) + "," + str(z)
	if not fires.has(key):
		var scene = load("res://effects/Fire.tscn")
		var instance = scene.instance()
		instance.translation = TreeMap.map_to_world(x, 0, z)
		add_child(instance)
		fires[key] = instance

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
		for xx in range(pos.x-1,pos.x+2):
			for zz in range(pos.z-1,pos.z+2):
				if xx != pos.x or zz != pos.z:

					var direction_factor = 0.1
					if wind_direction == 0: # North
						if zz > pos.z:
							direction_factor = 0.8
					elif wind_direction == 1: # East
						if xx > pos.x:
							direction_factor = 0.8
					elif wind_direction == 2: # South
						if zz > pos.z:
							direction_factor = 0.8
						pass
					else:                         # West
						if xx < pos.x:
							direction_factor = 0.8
						pass

					var kkey =  str(xx) + "," + str(zz)
					var cell_content = TreeMap.get_cell_item(xx,0, zz)
					if cell_content >= 0: # Trees
						if rng.randf_range(0, 1) < direction_factor:
							fires_to_add.append([xx, zz])
	return fires_to_add

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
	_update_fire_spread()
