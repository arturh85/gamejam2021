extends Control

func _on_HUDStatus_mouse_entered():
	$"../../".mouseInHUD = true
	
func _on_HUDStatus_mouse_exited():
	$"../../".mouseInHUD = false
	
	

func _ready():
	var world = gamestate.world()
	world.connect("wind_direction_changed", self, "wind_direction_changed")
	world.connect("energy_changed", self, "energy_changed")
	world.connect("resources_changed", self, "resources_changed")
	world.connect("co2_level_changed", self, "co2_level_changed")
	resources_changed(world.resources)
	energy_changed(world.energy_current)

func direction_label(direction):
	if direction == 0:
		return "North"
	elif direction == 1:
		return "East"
	elif direction == 2:
		return "South"
	elif direction == 3:
		return "West"

func wind_direction_changed(direction):
	$"Label-WindDirection".text = direction_label(direction)

func energy_changed(energy):
	$"Label-Energy".text = str(int(energy))

func resources_changed(resources):
	$"Label-Resources".text = str(resources)

func co2_level_changed(co2):
	var color = "whte"
	if co2 >= 200:
		color = "red"
	elif co2 >= 100:
		color = "yellow"
	$"Label-CO2".bbcode_text =  "[color=" + color + "]" + str(co2) + "[/color]"
