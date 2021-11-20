extends ColorRect

func _ready():
	var options = $OptionButton
	options.add_item("Fire", 0)
	options.add_item("SolarCell", 1)
	options.add_item("Bulldozer", 2)
	options.add_item("Tree", 3)

	options.select(0)
