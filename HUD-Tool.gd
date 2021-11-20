extends ColorRect

func _ready():
	var options = $OptionButton
	if options.items.size() == 0:
		options.add_item("Fire", 0)
		options.add_item("Tree", 1)
		options.add_item("Bulldozer", 2)
		options.add_item("SolarCell", 3)
		options.add_item("Battery", 4)
		options.add_item("PowerLine", 5)
		options.add_item("Farm", 6)
		options.add_item("WaterTower", 7)
		options.add_item("Silo", 8)

		options.select(0)
