extends GridMap

var fires = {}
var wind_direction = 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_fire(x, z):
	var key = str(x) + "," + str(z)
	if not fires.has(key):
		var scene = load("res://Fire.tscn")
		var instance = scene.instance()
		instance.translation = map_to_world(x, 0, z)
		add_child(instance)
		fires[key] = instance
	

func _on_Timer_timeout():
	var fires_to_add = []

	var wind_change = rng.randf_range(-10.0, 10.0)
	if wind_change < -7:
		wind_direction = wrapi(wind_direction - 1, 0, 4)
	if wind_change > 7:
		wind_direction = wrapi(wind_direction + 1, 0, 4)
	
	for cell in get_used_cells():
			var key = str(cell.x) + "," + str(cell.z)
			if fires.has(key):
				for xx in range(cell.x-1,cell.x+2):
					for zz in range(cell.z-1,cell.z+2):
						if xx != cell.x or zz != cell.z:
							var kkey =  str(xx) + "," + str(zz)
							var cell_content = get_cell_item(xx,0, zz)
							if cell_content == 2: # Trees
								if rng.randi_range(0, 10) > 7:
									fires_to_add.append([xx, zz])
	for key in fires_to_add:
		add_fire(key[0], key[1])