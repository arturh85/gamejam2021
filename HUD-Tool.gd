extends ColorRect

func _ready():
	var options = $OptionButton
	options.add_item("Fire", 1)
	options.add_item("SolarCell", 2)

	options.select(0)
