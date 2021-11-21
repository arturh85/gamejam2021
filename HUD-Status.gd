extends ColorRect



func _ready():
   $"../..".connect("wind_direction_changed", self, "wind_direction_changed")
   $"../..".connect("energy_changed", self, "energy_changed")
   $"../..".connect("resources_changed", self, "resources_changed")
   $"../..".connect("co2_level_changed", self, "co2_level_changed")

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
	print("label ", energy)
	$"Label-Energy".text = str(energy) + "%"

func resources_changed(resources):
	$"Label-Resources".text = str(resources)

func co2_level_changed(co2):
	$"Label-CO2".text =  str(co2)
