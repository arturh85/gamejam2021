extends ColorRect


onready var GameGrid = get_node("../../GridMap")

func _ready():
   GameGrid.connect("wind_direction_changed", self, "wind_direction_changed")

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
	$"Label-WindDirection".text = "Wind Direction: " + direction_label(direction)
